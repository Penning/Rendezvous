// Adam Oxner

//////////////////////////////////////////////////////////////////////////
// notify a user of meeting
// input is object type User
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.define("notifyInit", function (request, response) {
    alert("about to notify...");

    // Find user
    var userQuery = new Parse.Query(Parse.User);
    userQuery.equalTo("objectId", request.object.objectId);

    // Find devices associated user
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.matchesQuery('user', userQuery);

    // Send push notification to query
    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: request.object.get("name") + " wants to meet!",
            badge: "Increment",
        }
    }, {
        success: function () {
            // Push was successful
            alert("Push sent to " + request.object.get("name"));
        },
        error: function (error) {
            // Handle error
            alert("Error: " + error.code + " " + error.message);
        }
    });

});

Parse.Cloud.define("notifyAllResponded", function (request, response) {
    alert("Notifying meeting creator of total response");

    // Find the user who created meeting
    var userQuery = new Parse.Query(Parse.User);
    userQuery.equalTo("admin_fb_id", request.object.admin_fb_id);

    // Find creators device
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.matchesQuery('user', userQuery);

    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: "Please choose a location!",
            meetingID: request.object.objectId,
        },
    }, {
        success: function () {
            // Push was successful
            alert("Push sent to " + request.object.get("name"));
        },
        error: function (error) {
            // Handle error
            alert("Error: " + error.code + " " + error.message);
        }
    });
});

//////////////////////////////////////////////////////////////////////////
// runs after Meeting object saved
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.beforeSave("Meeting", function (request, response) {
    var meeting = request.object;

    // check if object is new
    if (meeting.get("status") == "initial") {

        invites = request.object.get("invites");

        for (var i = 0; i < invites.length; ++i) {

            // Find user
            var userQuery = new Parse.Query(Parse.User);
            userQuery.equalTo("facebook_id", invites[i]);
            userQuery.find({
                success: function (results) {
                    // send invites to users
                    for (var i = 0; i < results.length; i++) {
                        Parse.Cloud.run('notifyInit', result[i]);
                    }
                },
                error: function (error) {
                    // error
                    alert("Error: " + error.code + " " + error.message);
                }
            });

        };
        // set state to open once invites are out
        meeting.set("status", "open");
        response.success();
    }

    else if (meeting.get("status") == "open") {
        meeting.get("num_responded").increment;

        if (meeting.get("num_responded") == meeting.get("meeters").length) {
            // everyone has responded to the invite -- push notification back to creator
            if (meeting.get("isComeToMe") == true) {
                // creators location is common location by default
            }
            else {
                // get accepters locations and calculate the common lat long
                var latitude_sum = 0;
                var longitude_sum = 0;
                for (var i = 0; i < meeting.get("meeter_locations").length; ++i) {
                    latitude_sum += meeting.get("meeter_locations")[i].latitude;
                    longitude_sum += meeting.get("meeter_locations")[i].longitude;
                }
                var commonGeoPoint =
                    new Parse.Geopoint(latitude_sum / meeting.get("meeter_locations").length, longitude_sum / meeting.get("meeter_locations").length);
                meeting.set("final_meeting_location", commonGeoPoint);

            }
            meeting.set("status", "closed");
            Parse.Cloud.run('notifyAllResponded', meeting.get("admin_fb_id"));
        }

        else {
            // not everyone has responded yet. 
        }

        response.success;
    }

    else if (meeting.get("status") == "closed") {
        // saving final location -- need to notify all accepters of official meeting place 
    }

    else if (meeting.get("status") == "final") {
        // saving historically? deleting?
    }


});

/*
//////////////////////////////////////////////////////////////////////////
// notify a user of meeting
// input is a location and a Meeting's objectId
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.define("addLocationToMeeting", function(request, response){

	location = request.params.location;
	meetingId = request.params.meetingId;

	// find meeting
	var userQuery = new Parse.Query("Meeting");
	userQuery.equalTo("objectId", meetingId); // not working
	query.find({
		success: function(results) {
		    // add location
		    result[0].add("locations", location);
		    result[0].save();
		    alert("saved new location");
	  	},
		error: function(error) {
			// error
	    	alert("Error: " + error.code + " " + error.message);
		}
	});	


});

*/
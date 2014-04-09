// Adam Oxner & Tim Wood

//////////////////////////////////////////////////////////////////////////
// notify a user of meeting
// input is facebook_id of user
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.define("notifyInit", function (request, response) {
    alert("about to notify...");
    // Find user
    var userQuery = new Parse.Query(Parse.User);
    userQuery.startsWith("facebook_id", request.params.facebook_id);

    userQuery.first({
        success: function (object) {
            alert("found user to notify: " + object.get("facebook_id"));
            // Find devices associated user
            var pushQuery = new Parse.Query(Parse.Installation);
            pushQuery.startsWith("deviceToken", object.get("device_token"));


            // Send push notification to query
            Parse.Push.send({
                where: pushQuery,
                data: {
                    alert: "Rendezvous with " + Parse.User.current().get("name") + "!",
                    badge: "Increment",
                }
            }, {
                success: function () {
                    // Push was successful
                    alert("Push sent to someone!");
                    response.success();
                },
                error: function (error) {
                    // Handle error
                    alert("Error: " + error.code + " " + error.message);
                    response.error(error);
                }
            });

        },
        error: function (error) {
            alert("Error: " + error.code + " " + error.message);
            response.error(error);
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
            alert("notifyAllResponded -- notification sent to " + request.object.get("name"));
        },
        error: function (error) {
            // Handle error
            alert("notifyAllResponded pushError: " + error.code + " " + error.message);
        }
    });
});

// input is relevant meeting objectId
Parse.Cloud.define("forceCloseMeeting", function (request, response) {
    alert("forceCloseMeeting called");
    var meeting;
    var meetingQuery = new Parse.Query(Parse.User);
    meetingQuery.equalTo("objectId", request.params.objectId);
    meetingQuery.get(request.params.objectId, {
        success: function(object) {
            meeting = object;
            // object is an instance of Parse.Object.
        },

        error: function(object, error) {
            // error is an instance of Parse.Error.
            return;
        },
    });
    if (!meeting.get("status", "open")) {
        return;
    }

    // closing meeting -- push notification back to creator
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

        // dont notify since meeting is closing manually
        //Parse.Cloud.run('notifyAllResponded', meeting.get("admin_fb_id"));
 

});

Parse.Cloud.define("notifyFinalLocation", function (request, response) {

});



//////////////////////////////////////////////////////////////////////////
// runs after Meeting object saved
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.beforeSave("Meeting", function (request, response) {
    alert("beforeSave called -- meeting object");
    var meeting = request.object;

    // check if object is new
    if (meeting.get("status") == "initial") {

        invites = meeting.get("invites");
        meeting.set("num_responded", 1);
        alert(invites[0]);
        

        for (var i = 0; i < invites.length; ++i) {
            // Find user
            var query = new Parse.Query(Parse.User);
            query.startsWith("facebook_id", invites[i].toString());
            query.first({
                success: function (object) {
                    alert("about to call notifyInit: " + object.get("facebook_id"));

                    Parse.Cloud.run('notifyInit', { facebook_id: object.get("facebook_id") }, {
                        success: function (result) {
                            alert("notifyInit returned successfully");
                            response.success();
                        },
                        error: function (error) {
                            response.error();
                        }
                    });
                    
                },
                error: function (error) {
                    alert("Error: " + error.code + " " + error.message);
                    response.error(error);
                }
            });

        };
        // set state to open once invites are out
        meeting.set("status", "open");
        alert("success! -- meeting is " + meeting.get("status"));
    }

    else if (meeting.get("status") == "open") {
        meeting.set("num_responded", meeting.get("num_responded") + 1);

        if (meeting.get("num_responded") == meeting.get("invites").length) {
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

        response.success();
    }

    else if (meeting.get("status") == "closed") {
        // saving final location -- need to notify all accepters of official meeting place 
        response.success();
    }

    else if (meeting.get("status") == "final") {
        // saving historically? deleting?
        response.success();
    }
    else {
        response.error();
    }

    //response.success();


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
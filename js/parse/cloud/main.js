// Adam Oxner & Tim Wood

//////////////////////////////////////////////////////////////////////////
// notify a user of meeting
// input is facebook_id of user, object_id of meeting
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
                    objectId: request.params.objectId,
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

// input is admin_fb_id of meeting
Parse.Cloud.define("notifyAllResponded", function (request, response) {
    alert("Notifying meeting creator of total response");

    // Find the user who created meeting
    var userQuery = new Parse.Query(Parse.User);
    userQuery.startsWith("admin_fb_id", request.params.admin_fb_id);

    // Find creators device
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.matchesQuery('user', userQuery);

    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: "Choose a location for your Rendezvous!",
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
                new Parse.Geopoint( (latitude_sum / meeting.get("meeter_locations").length) , (longitude_sum / meeting.get("meeter_locations").length ));
            meeting.set("final_meeting_location", commonGeoPoint);

        }
        meeting.set("status", "closed");
});

// input is facebook_id of user, name of location, address of location
Parse.Cloud.define("notifyFinalLocation", function (request, response) {
    alert("notifying user of final location.");
    // Find user
    var userQuery = new Parse.Query(Parse.User);
    userQuery.startsWith("facebook_id", request.params.facebook_id);

    userQuery.first({
        success: function (object) {
            alert("found user to notify -- final location: " + object.get("facebook_id"));
            // Find devices associated user
            var pushQuery = new Parse.Query(Parse.Installation);
            pushQuery.startsWith("deviceToken", object.get("device_token"));


            // Send push notification to query
            Parse.Push.send({
                where: pushQuery,
                data: {
                    alert: "Ready, Set, Go!",
                    loc_name: request.params.location_name,
                    loc_address: reuqest.params.loc_address,
                }
            }, {
                success: function () {
                    // Push was successful
                    alert("Final notification push -- successful!");
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



//////////////////////////////////////////////////////////////////////////
// runs before Meeting object saved
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.beforeSave("Meeting", function (request, response) {
    var meeting = request.object;

    // check if object is new
    if (meeting.get("status") == "initial") {
        alert("status == initial");

        var invites = meeting.get("invites");
        meeting.set("num_responded", 0);
        alert(invites[0]);
        
        var query = new Parse.Query(Parse.User);
        query.containedIn("facebook_id", invites);
        query.find().then(function (results) {
            alert("results found " + results.length);
            // Create a trivial resolved promise as a base case.

            var promise = Parse.Promise.as();
            results.forEach(function (result) {
                // For each item
                promise = promise.then(function () {
                    return Parse.Promise.when(Parse.Cloud.run('notifyInit',
                        { facebook_id: result.get("facebook_id"), objectId: meeting.get("objectId") }));
                });
            });
            promise.then(function () {
                // all notifications sent out
                alert("Opening meeting for location insertion");
                meeting.set("status", "open");
                response.success();
            });

        }, function (error) {
                response.error();
        });
    }

    else if (meeting.get("status") == "open") {
        alert("meeting status == open");
        if (meeting.get("num_responded") == meeting.get("invites").length) {
            alert("everyone has responded");
            // everyone has responded to the invite -- push notification back to creator
            if (meeting.get("isComeToMe") == true) {
                // creators location is common location by default
            }
            else {
                alert("calculating common lat/long");
                // get accepters locations and calculate the common lat long
                var latitude_sum = 0;
                var longitude_sum = 0;
                for (var i = 0; i < meeting.get("meeter_locations").length; ++i) {
                    latitude_sum += meeting.get("meeter_locations")[i].latitude;
                    longitude_sum += meeting.get("meeter_locations")[i].longitude;
                }
                alert("latitude sum = " + latitude_sum + " longitude sum = " + longitude_sum);
                var commonGeoPoint =
                    new Parse.Geopoint( (latitude_sum / meeting.get("meeter_locations").length), (longitude_sum / meeting.get("meeter_locations").length) );
                meeting.set("final_meeting_location", commonGeoPoint);

            }
            //
            var promise = Parse.Promise.as();
            promise.then(function () {
                return Parse.Promise.when(Parse.Cloud.run('notifyAllResponded',
                    { admin_fb_id: meeting.get("admin_fb_id") }));
            }).then(function () {
                // all notifications sent out
                meeting.set("status", "closed");
                alert("closing meeting -- returning to client");
                response.success();
            }, function (error) {
                response.error();
            });
        }

        else {
            // not everyone has responded yet. 
        }
    }

    else if (meeting.get("status") == "closed") {
        // saving final location -- need to notify all accepters of official meeting place
        alert("saving closed meeting, pushing notifications to attendees");

        // get facebook ids of accepted meeters
        var fb_ids_accepted_users = meeting.get("fb_ids_accepted_users");
 
        var query = new Parse.Query(Parse.User);
        query.containedIn("facebook_id", fb_ids_accepted_users);
        query.find().then(function (results) {
            alert("results found: " + results.length);
            // Create a trivial resolved promise as a base case.

            var promise = Parse.Promise.as();
            results.forEach(function (result) {
                // For each accepted user -- notify of final locations
                promise = promise.then(function () {
                    return Parse.Promise.when(Parse.Cloud.run('notifyFinalLocation',
                        {
                            facebook_id: result.get("facebook_id"),
                            location_name: meeting.get("finalized_location").get("name"),
                            location_address: meeting.get("finalized_location").get("address"),
                        }));
                });
            });
            promise.then(function () {
                // all notifications sent out
                alert("final locations notifications sent - finalizing meeting");
                meeting.set("status", "final");
                response.success();
            });

        }, function (error) {
            response.error();
        });
    }

    else if (meeting.get("status") == "final") {
        // saving historically? deleting?
        response.success();
    }
    else {
        response.error();
    }

});

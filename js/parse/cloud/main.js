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
                    alert: "RSVP to " + Parse.User.current().get("name") + "!",
                    badge: "Increment",
                    type: "invite",
                    meetingId: request.params.meetingId,
                }
            }, {
                success: function () {
                    // Push was successful
                    alert("Push sent to " + object.get("name") + "!");
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

    var userQuery = new Parse.Query(Parse.User);
    userQuery.startsWith("facebook_id", request.params.admin_fb_id);

    userQuery.first({
        success: function (object) {
            alert("found user to notify: " + object.get("facebook_id"));
            // Find devices associated user
            var pushQuery = new Parse.Query(Parse.Installation);
            pushQuery.startsWith("deviceToken", object.get("device_token"));

            Parse.Push.send({
                where: pushQuery,
                data: {
                    alert: "Choose a location for your Rendezvous!",
                    meetingId: request.params.meetingId,
                    type: "choose_location",
                },
            }, {
                success: function () {
                    // Push was successful
                    alert("notifyAllResponded -- notification sent to " + request.params.admin_fb_id);
                    response.success();
                },
                error: function (error) {
                    // Handle error
                    alert("notifyAllResponded pushError: " + error.code + " " + error.message);
                    response.error();
                }
            });
        },
        error: function (error) {
            alert("Error: " + error.code + " " + error.message);
            response.error(error);
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
        success: function (object) {
            meeting = object;
            // object is an instance of Parse.Object.
        },

        error: function (object, error) {
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
            new Parse.Geopoint((latitude_sum / meeting.get("meeter_locations").length), (longitude_sum / meeting.get("meeter_locations").length));
        meeting.set("final_meeting_location", commonGeoPoint);

    }
    meeting.set("status", "closed");
    meeting.save();
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
                    type: "final",
                    meetingId: request.params.meetingId,
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
    var meetingQuery = new Parse.Query("Meeting");
    // check if object is new
    if (meeting.get("status") == "initial") {
        alert("beforeSave: status == initial");
        meeting.set("num_responded", 0);
        meeting.set("status", "open")
        meeting.set("just_opened", true);
        response.success();
    }

    else if (meeting.get("status") == "open") {
        alert("beforeSave - meeting status == open");
        meeting.set("just_opened", false);
        if (meeting.get("isComeToMe") == true) {
            // creators location is common location by default
        }
        else {
            alert("calculating common lat/long");
            // get accepters locations and calculate the common lat long
            var latitude_sum = 0;
            var longitude_sum = 0;
            if (meeting.get("meeter_locations") != undefined) {
                //response.success;
                for (var i = 0; i < meeting.get("meeter_locations").length; ++i) {
                    latitude_sum += meeting.get("meeter_locations")[i].latitude;
                    longitude_sum += meeting.get("meeter_locations")[i].longitude;
                }
                alert("latitude sum = " + latitude_sum + " longitude sum = " + longitude_sum);
                var commonGeoPoint =
                    new Parse.GeoPoint({ latitude: (latitude_sum / meeting.get("meeter_locations").length), longitude: (longitude_sum / meeting.get("meeter_locations").length) });
                meeting.set("final_meeting_location", commonGeoPoint);
            }
        }
        if (meeting.get("num_responded") == meeting.get("invites").length) {
            // everyone has responded to the invite -- close meeting and notify leader
            alert("everyone has responded");
            meeting.set("status", "closed");
            response.success();
        }
        else {
            // not everyone has responded yet. 
            response.success();
        }
    }

    else if (meeting.get("status") == "closed") {
        // saving final location -- need to notify all accepters of official meeting place
        if (Parse.User.current().get("facebook_id") != meeting.get("admin_fb_id")) {
            alert("non-admin saving closed meeting -- id: " + Parse.User.current().get("facebook_id") + "adminid: " + meeting.get("admin_fb_id"));
            response.success();
            return;
        };
        meeting.set("just_opened", false);
        alert("saving closed meeting -- setting status to final");
        meeting.set("status", "final");
        response.success();
    }

    else if (meeting.get("status") == "final") {
        // saving historically? deleting?
        meeting.set("status", "savingfinal");
        response.success();
    }
    else {
        response.error();
    }
});


//////////////////////////////////////////////////////////////////////////
// runs after Meeting object saved
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.afterSave("Meeting", function (request) {
    var meetingId = request.object.id;
    alert("meetingid = " + request.object.id);
    var meetingQuery = new Parse.Query("Meeting");
    meetingQuery.equalTo("objectId", meetingId);
    var meeting;
    meetingQuery.first({
        success: function (object) {
            meeting = object;
        },
        error: function (error) {
            alert("Error: " + error.code + " " + error.message);
        }
    }).then(function () {
        if (meeting.get("status") == "initial") {
            alert("error: afterSave -- status == initial");
        }
        else if (meeting.get("just_opened")) {
            alert("meeting just created -- notifying invitees of meeting");
            var invites = meeting.get("invites");
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
                            { facebook_id: result.get("facebook_id"), meetingId: meeting.id }));
                    });
                });
            }, function (error) {
            });
        }

        else if (meeting.get("status") == "closed") {
            alert("afterSave -- meeting status == closed");

            var promise = Parse.Promise.as();
            promise.then(function () {
                return Parse.Promise.when(Parse.Cloud.run('notifyAllResponded',
                    { admin_fb_id: meeting.get("admin_fb_id"), meetingId: meeting.id, }));
            }, function (error) {

            });
        }
        else if (meeting.get("status") == "final") {
            // saving final location -- need to notify all accepters of official meeting place
            alert("saving final meeting, pushing location to attendees");

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
                                meetingId: meeting.id,
                            }));
                    });
                });
            }, function (error) {

            });
        }
        else {
            //response.error();
        }
    });
});

Parse.Cloud.beforeDelete("Meeting", function(request, response){
   var meeting = request.object;
    var query = new Parse.Query("Location");

    var meeting = request.object;
    var location = request.object.get("finalized_location");
    if (location == undefined) {
        response.success();
        return;
    }
    
    location.destroy({
        success: function(object){
            alert("location destroyed: objectid = " + object.id);
            response.success();
        },
        error: function(error){
            response.error();
        }    
    });
});
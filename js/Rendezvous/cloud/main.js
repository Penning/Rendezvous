// Adam Oxner

//////////////////////////////////////////////////////////////////////////
// notify a user of meeting
// input is object type User
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.define("notifyInit", function(request, response){

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
		  	success: function() {
		    	// Push was successful
		  	},
		  	error: function(error) {
		    	// Handle error
		    	alert("Error: " + error.code + " " + error.message);
		  	}
	});

});

//////////////////////////////////////////////////////////////////////////
// runs after Meeting object saved
//////////////////////////////////////////////////////////////////////////
Parse.Cloud.afterSave("Meeting", function(request) {

	
	// check if object is new
	if (request.object.get("status") != "initial") {
		return;
	};
	

	request.object.fetch({
		success: function(meeting){
			meeting.fetch({
				success:function(m2){

					invites = m2.object.get("invites");

					for (var i = 0; i < invites.length; ++i) {

						// Find user
						var userQuery = new Parse.Query(Parse.User);
						userQuery.equalTo("facebook_id", invites[i]); // not working
						userQuery.find({
							success: function(results) {
							    // send invites to users
							    for (var i = 0; i < results.length; i++) { 
							    	Parse.Cloud.run('notifyInit', result[i]);
							    }
						  	},
							error: function(error) {
								// error
						    	alert("Error: " + error.code + " " + error.message);
							}
						});

					};


					// set state to open once invites are out
					m2.object.set("status", "open");
					m2.object.save();

				},
				error: function(error) {
					// error
			    	alert("Error: " + error.code + " " + error.message);
				}
			});
		},
		error: function(error) {
			// error
	    	alert("Error: " + error.code + " " + error.message);
		}
	});

	
	

});

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
	  	},
		error: function(error) {
			// error
	    	alert("Error: " + error.code + " " + error.message);
		}
	});	


});


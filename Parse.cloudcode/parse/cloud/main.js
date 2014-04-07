
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("Meeting", function(request) {
  query = new Parse.Query("Meeting");
  query.get(request.object.get("meeting").id, {
    success: function(meeting) {
	  // determine we're in the 'invitation' state
      meeting.increment("numResponded");
	  if(numResponded == meeting.meeters.length){
		// everyone has responded. Call commonlatlong to return location or if
		if(meeting.isComeToMe){
		// get initializer location and return that instead
		}
		
		// send push notification with common lat long to initializer phone
	  }
	  
      meeting.save();
    },
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
    }
  });
});
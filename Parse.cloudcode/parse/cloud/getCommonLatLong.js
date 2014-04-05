
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("getAverageLatLong", function (request, response) {
    // This is assuming the name of the parse object class is 'Meeting'
    var query = new Parse.Query("Meeting");
    query.find({
        success: function (results) {
            if (results.length > 1) {
                // error: multiple meeting objects saved on cloud
                // 'Meeting' object intended to be singleton on server
            }
            var meeting_list = results[0].meeters;
            var latitude_sum = 0;
            var longitude_sum = 0;
            for (var i = 0; i < meeting_list.length; ++i) {
                latitude_sum += meeting_list[i].latitude;
                longitude_sum += meeting_list[i].longitude;
            }
            var common_lat_long =
            { "latitude": latitude_sum / meeting_list.length, "longitude": longitude_sum / meeting_list.length };

            // need to restructure to send array with the response 
            response.success(common_lat_long);
        },
        error: function () {
            response.error("movie lookup failed");
        }
    });
});

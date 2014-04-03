//
//  LocationSuggestionsLookup.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/3/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "LocationSuggestionsLookup.h"

@implementation LocationSuggestionsLookup

//yelp url: http://api.yelp.com/v2/search?term=food&ll=37.788022,-122.399797

- (void) getSuggestions:(Meeting *) meeting {
    //Get suggestions for each category
    for(NSString *category in meeting.reasons) {
        NSLog(@"%@ results: ", category);
        //40,000 meters = 25 miles
        //Searching w/in 0.5 mile distance from central location (800m)
        NSString *url = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?category_filter=%@&radius_filter=800&ll=%@,%@", category, meeting.latitude, meeting.longitude];

        //    NSLog(@"%@", url);

        NSURL *yelpURL = [NSURL URLWithString:url];

        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:yelpURL] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

            if (!error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSArray *results = [[[[json objectForKey:@"response"] objectForKey:@"groups"] firstObject] objectForKey:@"items"];

                int i = 1;
                for (NSDictionary *location in results) {
                    NSLog(@"Suggestion #%i: %@", i++, location);
                    //                [appDelegate.tripManager addVenueToDestinationFromAPI:venue :city];
                }
                NSLog(@"%lu Locations found for destination.", results.count);
                
            } else {
                NSLog(@"ERROR: %@", error);
            }
        }];
    }
}

@end

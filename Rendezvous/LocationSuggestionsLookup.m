//
//  LocationSuggestionsLookup.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/3/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "LocationSuggestionsLookup.h"
#import "MeetingLocation.h"
#import "OAuthConsumer.h"

@implementation LocationSuggestionsLookup {
    NSMutableArray *locations;
}

@synthesize locationViewController = _locationViewController;

//yelp url: http://api.yelp.com/v2/search?term=food&ll=37.788022,-122.399797

- (void) getSuggestions:(Meeting *) meeting {
    NSLog(@"GETTING SUGGESTIONS...");
    meeting.reasons = [[NSMutableArray alloc] init];
    //Using default reasons for testing
    [meeting.reasons addObject:@"restaurants"];
    [meeting.reasons addObject:@"bars"];
    [meeting.reasons addObject:@"coffee"];

    locations = [[NSMutableArray alloc] init];
    _locationViewController.suggestions = [[NSMutableArray alloc] init];

    //Get suggestions for each category
    for(NSString *category in meeting.reasons) {
        NSLog(@"Searching for %@", category);

        //Using default UMICH lat/lng for testing
        meeting.latitude = [NSNumber numberWithDouble:42.27806];
        meeting.longitude = [NSNumber numberWithDouble:-83.73823];

        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"5G6EbBnwRp9R-Dm_6324QA" secret:@"BNU1YuTSMRnz9OP-Lr7KKWjkCvM"];
        OAToken *token = [[OAToken alloc] initWithKey:@"FDPzfW0-aA83L40RNgV5TrJC1tvzfDv-" secret:@"ji6etDgelybVQzWO-Ell8KeB49w"];

        id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
        NSString *realm = nil;


        //MAX radius is 40,000 meters = 25 miles
        //Searching w/in 0.5 mile distance from central location (800m)
        //Limit 5 items/category
        NSString *url = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?category_filter=%@&radius_filter=800&limit=5&ll=%@,%@", category, meeting.latitude, meeting.longitude];

//        NSLog(@"%@", url);

        NSURL *yelpURL = [NSURL URLWithString:url];

        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:yelpURL
                                                                       consumer:consumer
                                                                          token:token
                                                                          realm:realm
                                                              signatureProvider:provider];
        [request prepare];

        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

            if (!error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSArray *results = [json objectForKey:@"businesses"];
//                NSLog(@"Results: %@", results);

//                int i = 1;
                for (NSDictionary *location in results) {
//                    NSLog(@"Suggestion #%i: %@", i++, location);
                    MeetingLocation *meetingLocation = [[MeetingLocation alloc] initFromYelp:location];
                    if(![_locationViewController.suggestions containsObject:meetingLocation]) {
//                        [meetingLocation printInfoToLog];
                        [_locationViewController.suggestions addObject:meetingLocation];
                        [_locationViewController.tableView reloadData];
//                        NSLog(@"#suggestions = %lu", (unsigned long)[_locationViewController.suggestions count]);
                    }
                }
            } else {
                NSLog(@"ERROR: %@", error);
            }
        }];
//        NSLog(@"COUNT: %ld", (long)[self suggestionCount]);
    }
}

- (NSArray *) getSuggestionResults {
    NSLog(@"Locations count = %lu", (unsigned long)locations.count);
    return locations;
}

- (NSInteger) suggestionCount {
    return locations.count;
}

@end

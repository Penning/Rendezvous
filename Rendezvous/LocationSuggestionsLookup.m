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

- (void) getSuggestionsWithCoreData:(NSManagedObject *) meetingObject {
    Meeting *meeting = [[[Meeting alloc] init] toCoreData:meetingObject];
    [self getSuggestions:meeting];
    _locationViewController.meeting = meeting;
}

- (void) getSuggestions:(Meeting *) meeting {
    NSLog(@"GETTING LOCATION SUGGESTIONS!!!");

    locations = [[NSMutableArray alloc] init];
    _locationViewController.suggestions = [[NSMutableArray alloc] init];

    //Using default UMICH lat/lng for testing
    meeting.latitude = [NSNumber numberWithDouble:42.27806];
    meeting.longitude = [NSNumber numberWithDouble:-83.73823];

    //Get suggestions for each category
    if(meeting.reasons.count > 0) {
        for(NSString *category in meeting.reasons) {
            NSLog(@"Searching for %@", category);
            NSString *url = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?category_filter=%@&radius_filter=800&limit=8&ll=%@,%@", category, meeting.latitude, meeting.longitude];
            [self requestFromYelp:[NSURL URLWithString:url] :category];
        }
    } else {
        NSLog(@"Searching for ANY location");
        NSString *url = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?sort=1&radius_filter=800&limit=10&ll=%@,%@", meeting.latitude, meeting.longitude];
        [self requestFromYelp:[NSURL URLWithString:url] :@"None"];
    }
}

- (void) requestFromYelp: (NSURL *) yelpURL :(NSString *) category {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"5G6EbBnwRp9R-Dm_6324QA" secret:@"BNU1YuTSMRnz9OP-Lr7KKWjkCvM"];
    OAToken *token = [[OAToken alloc] initWithKey:@"FDPzfW0-aA83L40RNgV5TrJC1tvzfDv-" secret:@"ji6etDgelybVQzWO-Ell8KeB49w"];

    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;

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
            for (NSDictionary *location in results) {
                MeetingLocation *meetingLocation = [[MeetingLocation alloc] initFromYelp:location :category];
                if(![_locationViewController.suggestions containsObject:meetingLocation]) {
                    [_locationViewController.suggestions addObject:meetingLocation];
                    [_locationViewController.tableView reloadData];
                }
            }
        } else {
            NSLog(@"ERROR: %@", error);
        }
    }];
}

- (NSArray *) getSuggestionResults {
    NSLog(@"Locations count = %lu", (unsigned long)locations.count);
    return locations;
}

- (NSInteger) suggestionCount {
    return locations.count;
}

@end

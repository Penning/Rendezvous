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
    CLLocationManager *locationManager;
    NSNumber *longitude;
    NSNumber *latitude;
}

@synthesize locationViewController = _locationViewController;

//yelp url: http://api.yelp.com/v2/search?term=food&ll=37.788022,-122.399797

- (void) getSuggestionsWithCoreData:(NSManagedObject *) meetingObject {
    
    Meeting *meeting = [[[Meeting alloc] init] toCoreData:meetingObject];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Meeting"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:[meetingObject valueForKey:@"parse_object_id"] block:^(PFObject *foreignMeeting, NSError *error) {
        
        if (!error) {
            [meeting setLatitude:[NSNumber numberWithDouble:((PFGeoPoint *)[foreignMeeting valueForKey:@"final_meeting_location"]).latitude]];
            [meeting setLongitude:[NSNumber numberWithDouble:((PFGeoPoint *)[foreignMeeting valueForKey:@"final_meeting_location"]).longitude]];
            
            NSLog(@"Got final location: %@, %@", meeting.latitude, meeting.longitude);
            [self getSuggestions:meeting];
        }else{
            NSLog(@"Error getting final location: %@", error);
        }
        
    }];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [locationManager startUpdatingLocation];
    
    _locationViewController.meeting = meeting;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;

    if (currentLocation != nil) {
        latitude = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];
        longitude = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
        NSLog(@"Admin is @ (%@, %@)", latitude, longitude);
    }
}

- (void) getSuggestions:(Meeting *) meeting {
    NSLog(@"GETTING LOCATION SUGGESTIONS!!!");

    locations = [[NSMutableArray alloc] init];
    _locationViewController.suggestions = [[NSMutableArray alloc] init];

    //Using default admin lat/lng when finalized location hasn't been set!
    if(([meeting.latitude isEqual:[NSNumber numberWithInt:0]] && [meeting.longitude isEqual:[NSNumber numberWithInt:0]]) || meeting.isComeToMe) {
        meeting.latitude = latitude;
        meeting.longitude = longitude;
        NSLog(@"Updated to admin location: %@, %@", meeting.latitude, meeting.longitude);
    }

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
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", meetingLocation.name];
                NSArray *filteredArray = [_locationViewController.suggestions filteredArrayUsingPredicate:predicate];
                if([filteredArray count] == 0) {
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

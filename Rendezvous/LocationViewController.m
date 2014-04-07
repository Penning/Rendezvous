//
//  LocationViewController.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/23/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "LocationViewController.h"
#import "LocationSuggestionsLookup.h"
#import "LocationSuggestionCell.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"

@interface LocationViewController ()

@end

@implementation LocationViewController {
    LocationSuggestionsLookup *locationSuggestionsLookup;
    NSMutableArray *suggestions;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationSuggestionsLookup = [[LocationSuggestionsLookup alloc] init];
    Meeting *meeting = [[Meeting alloc] init];
//    [locationSuggestionsLookup getSuggestions:meeting];
    suggestions = [[NSMutableArray alloc] initWithArray:[locationSuggestionsLookup getSuggestionResults]];
    [self getSuggestions:meeting];
    NSLog(@"Suggestions: %@", suggestions);
    // Do any additional setup after loading the view.
}

- (void) getSuggestions:(Meeting *) meeting {
    NSLog(@"GETTING SUGGESTIONS...");
    meeting.reasons = [[NSMutableArray alloc] init];
    //Using default reasons for testing
    [meeting.reasons addObject:@"restaurants"];
    [meeting.reasons addObject:@"bars"];
    [meeting.reasons addObject:@"coffee"];

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
        NSString *url = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?category_filter=%@&radius_filter=800&limit=3&ll=%@,%@", category, meeting.latitude, meeting.longitude];

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
                    [meetingLocation printInfoToLog];
                    [suggestions addObject:meetingLocation];
                }

            } else {
                NSLog(@"ERROR: %@", error);
            }
        }];
        NSLog(@"COUNT: %ld", (long)[suggestions count]);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [locationSuggestionsLookup suggestionCount];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     LocationSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestion_cell"];
     if (cell == nil) {
         cell = [[LocationSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestion_cell"];
     }
 
     // Configure the cell...
     [cell initCellDisplay: [suggestions objectAtIndex:indexPath.row]];
 
     return cell;
 }

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

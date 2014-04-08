//
//  CurrentUser.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "CurrentUser.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Friend.h"

@implementation CurrentUser

- (void) initFromRequest:(NSDictionary *) userData {
    _name = userData[@"name"];
    _first_name = userData[@"first_name"];
    _last_name = userData[@"last_name"];

    _email = userData[@"email"];

    _gender = userData[@"gender"];

    _link = userData[@"link"];

    _facebookID = userData[@"id"];
    _pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", _facebookID]];
    
    [[PFUser currentUser] setObject:_facebookID forKey:@"facebook_id"];
    [[PFUser currentUser] saveInBackground];

//    NSLog(@"%@", userData);

    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *data = [result objectForKey:@"data"];
        _friends = [[NSMutableArray alloc] init];
        for (FBGraphObject<FBGraphUser> *friend in data) {
            [_friends addObject:[[Friend alloc] initWithObject:friend]];
//            NSLog(@"friend :%@", friend);
        }
        NSLog(@"Found %lu friends!", (unsigned long)_friends.count);
    }];
    
}

- (void) getMyInformation {
    [self performSelectorInBackground:@selector(backgroundInformation) withObject:nil];
}

- (void) backgroundInformation {
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];

    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
         
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            [self initFromRequest:userData];
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) getMeetingUpdates];
        }
    }];
}

- (NSURL *) getPictureURL {
    return _pictureURL;
}

@end

//
//  CurrentUser.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "CurrentUser.h"
#import <Parse/Parse.h>
#import "Friend.h"

@implementation CurrentUser

- (void) initFromRequest:(NSDictionary *) userData {
    _name = userData[@"name"];
    _first_name = userData[@"first_name"];
    _last_name = userData[@"last_name"];

    _gender = userData[@"gender"];

    _link = userData[@"link"];

    _facebookID = userData[@"id"];
    _pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", _facebookID]];

//    NSLog(@"%@", userData);

    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray *friends = result[@"data"];
        _friends = [[NSMutableArray alloc] init];
        for (NSDictionary<FBGraphUser>* friend in friends) {
            [_friends addObject:[[Friend alloc] initWithObject:friend]];
        }
        NSLog(@"Found %lu friends!", _friends.count);
    }];
}

- (void) getMyInformation {
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];

    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            [self initFromRequest:userData];
        }
    }];
}

- (NSURL *) getPictureURL {
    return _pictureURL;
}

@end

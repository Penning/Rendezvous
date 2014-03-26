//
//  CurrentUser.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "CurrentUser.h"
#import <Parse/Parse.h>

@implementation CurrentUser

- (void) initFromRequest:(NSDictionary *) userData {
    _name = userData[@"name"];
    _first_name = userData[@"first_name"];
    _last_name = userData[@"last_name"];

    _gender = userData[@"gender"];

    _link = userData[@"link"];

    _facebookID = userData[@"id"];
    _pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", _facebookID]];

    NSLog(@"%@", userData);

    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray *friends = result[@"data"];
        //        NSLog(@"%@", friends);
        int count = 0;
        for (NSDictionary<FBGraphUser>* friend in friends) {
//            NSLog(@"Found a friend: %@", friend.name);
            [_friends addObject:friend];
            count++;
        }
        NSLog(@"Found %i friends!", count);
    }];
}

- (NSURL *) getPictureURL {
    return _pictureURL;
}

@end

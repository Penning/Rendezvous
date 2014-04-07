//
//  Friend.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "Friend.h"

@implementation Friend {
    NSMutableData *imageData;
}

- (Friend *) initWithObject:(NSDictionary<FBGraphUser>*) friend {
    _name = friend.name;

    _facebookID = friend.id;

    _email = [friend objectForKey:@"email"];

    _pictureURL = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    // NSLog(@"PICTURE URL: %@", _pictureURL);

    return self;
}

- (NSURL *) getPictureURL {
    return _pictureURL;
}

@end

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
    self = [super init];
    
    _name = friend.name;
    
    
    _first_name = [[friend.name componentsSeparatedByString:@" "] objectAtIndex:0];
    if ([friend.name componentsSeparatedByString:@" "].count > 1) {
        _last_name = [[friend.name componentsSeparatedByString:@" "] objectAtIndex:1];
    }
    

    _facebookID = friend.id;

    _email = [friend objectForKey:@"email"];

    _pictureURL = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    
    
    return self;
}

- (Friend *) initWithManagedObject:(NSManagedObject *) person{
    self = [super init];
    
    _name = [person valueForKey:@"name"];
    _first_name = [person valueForKey:@"first_name"];
    _last_name = [person valueForKey:@"last_name"];
    _facebookID = [person valueForKey:@"facebook_id"];
    
    return self;
}

- (NSURL *) getPictureURL {
    return _pictureURL;
}

@end

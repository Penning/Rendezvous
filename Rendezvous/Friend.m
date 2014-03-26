//
//  Friend.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "Friend.h"

@implementation Friend

- (Friend *) initWithObject:(NSDictionary<FBGraphUser>*) friend {
    _name = friend.name;
    _first_name = friend.first_name;
    _last_name = friend.last_name;
    
    _facebookID = friend.id;

    return self;
}

@end

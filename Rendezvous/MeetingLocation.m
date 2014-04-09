//
//  MeetingLocation.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/3/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "MeetingLocation.h"

@implementation MeetingLocation

-(MeetingLocation *) initFromYelp:(NSDictionary *) data {
    _id = [data objectForKey:@"id"];
    _name = [data objectForKey:@"name"];
    _distanceFromLoc = [data objectForKey:@"distance"];

    _imageURL = [data objectForKey:@"image_url"];
    _url = [data objectForKey:@"url"];

    _phone = [data objectForKey:@"display_phone"];

    NSDictionary *location = [data objectForKey:@"location"];
    _snippetText = [location objectForKey:@"snippet_text"];

    _streetAddress = [location objectForKey:@"address"];
    _city = [location objectForKey:@"city"];
    _state = [location objectForKey:@"state_code"];
    _address = [[location objectForKey:@"display_address"] objectAtIndex:1];

    return self;
}

-(void) printInfoToLog {
    NSLog(@"%@", _name);
}

@end

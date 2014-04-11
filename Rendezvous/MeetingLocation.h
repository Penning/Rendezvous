//
//  MeetingLocation.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/3/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeetingLocation : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *category;

@property (strong, nonatomic) NSNumber *distanceFromLoc;

@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) NSString *phone;

@property (strong, nonatomic) NSString *snippetText;

@property (strong, nonatomic) NSString *streetAddress;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *address;

-(MeetingLocation *) initFromYelp:(NSDictionary *) data :(NSString *) category;
-(void) printInfoToLog;

@end

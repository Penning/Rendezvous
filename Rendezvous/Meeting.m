//
//  Meeting.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/29/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "Meeting.h"

@implementation Meeting{
    BOOL comeToMe;
}

@synthesize name = _name;
@synthesize description = _description;
@synthesize meeters = _meeters;
@synthesize reasons = _reasons;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

@synthesize acceptedMeeters = _acceptedMeeters;

- (id)init{
    self = [super init];
    
    comeToMe = NO;
    
    return self;
}

- (void)setComeToMe:(BOOL)option{
    comeToMe = option;
}

- (BOOL)isComeToMe{
    return comeToMe;
}

- (Meeting *)toCoreData:(NSManagedObject *) meeting_object {
    
    _parseObjectId = [meeting_object valueForKey:@"parse_object_id"];
    _name = [meeting_object valueForKey:@"meeting_name"];
    NSSet *rez = [meeting_object mutableSetValueForKeyPath:@"reasons"];
    _reasons = [[NSMutableArray alloc] init];
    for (NSString *r in rez) {
        [_reasons addObject: [r valueForKey:@"reason"]];
        NSLog(@"Reason: %@", [r valueForKey:@"reason"]);
    }
    return self;
}

- (Meeting *)fromPFObject:(PFObject *) meeting_object {
    
    _parseObjectId = [NSString stringWithFormat:@"%@", meeting_object.objectId];
    _name = [meeting_object valueForKey:@"name"];
    NSSet *rez = [meeting_object mutableSetValueForKeyPath:@"reasons"];
    _reasons = [[NSMutableArray alloc] init];
    for (NSString *r in rez) {
        [_reasons addObject: r];
    }
    _latitude = [NSNumber numberWithDouble:((PFGeoPoint *)[meeting_object valueForKey:@"final_meeting_location"]).latitude];
    _longitude = [NSNumber numberWithDouble:((PFGeoPoint *)[meeting_object valueForKey:@"final_meeting_location"]).longitude];
    
    return self;
}

@end

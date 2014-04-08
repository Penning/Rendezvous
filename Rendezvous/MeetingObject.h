//
//  MeetingObject.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/8/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PersonObject.h"

@interface MeetingObject : NSManagedObject

@property (strong, nonatomic) NSDate *created_date;
@property (strong, nonatomic) NSNumber *is_ComeToMe;
@property (strong, nonatomic) NSNumber *is_old;
@property (strong, nonatomic) NSString *meeting_description;
@property (strong, nonatomic) NSString *meeting_name;
@property (strong, nonatomic) NSString *parse_object_id;

@property (strong, nonatomic) NSObject* admin;
@property (strong, nonatomic) NSSet *invites; // set of PersonObject's
@property (strong, nonatomic) NSSet *reasons; // set of ReasonObject's

@end

//
//  PersonObject.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/8/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MeetingObject.h"

@interface PersonObject : NSManagedObject

@property (strong, nonatomic) NSString *facebook_id;
@property (strong, nonatomic) NSString *first_name;
@property (strong, nonatomic) NSString *last_name;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) MeetingObject *administors;
@property (strong, nonatomic) MeetingObject *meeting;

@end

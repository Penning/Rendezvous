//
//  ReasonObject.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/8/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MeetingObject.h"

@interface ReasonObject : NSManagedObject

@property (strong, nonatomic) NSString *reason;

@property (strong, nonatomic) MeetingObject *meeting;

@end

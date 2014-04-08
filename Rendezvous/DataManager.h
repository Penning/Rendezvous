//
//  DataManager.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/8/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meeting.h"

@interface DataManager : NSObject

- (void) createMeeting:(Meeting *)meeting withInvites:(NSArray *)invites withReasons:(NSArray *)reasons;

- (void) fetchMeetingUpdates;

- (void) deleteMeeting:(NSString *)parseObjectId;
- (void) deleteMeetingLocally:(NSString *)parseObjectId;
- (void) deleteMeetingOnServer:(NSString *)parseObjectId;

@end

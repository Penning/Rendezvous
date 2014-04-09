//
//  DataManager.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/8/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meeting.h"
#import "MeetingObject.h"

@interface DataManager : NSObject

- (void) createMeeting:(Meeting *)meeting withInvites:(NSArray *)invites withReasons:(NSArray *)reasons;

- (void) fetchMeetingUpdates;

- (void) deleteMeetingWithId:(NSString *)parseObjectId;
- (void) deleteMeetingLocallyWithId:(NSString *)parseObjectId;
- (void) deleteMeetingOnServerWithId:(NSString *)parseObjectId;
- (void) deleteMeetingLocally:(MeetingObject *)meetingObject;

- (void) deleteMeetingSoft:(MeetingObject *)meetingObject;

@end

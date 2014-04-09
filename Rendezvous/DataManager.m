//
//  DataManager.m
//  Rendezvous
//
//  Created by Adam Oxner on 4/8/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "Friend.h"

@implementation DataManager{
    AppDelegate *appDelegate;
    NSManagedObject *tempMeeting;
}


- (DataManager *)init{
    self = [super init];
    
    if (!appDelegate) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

// creating
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) createMeeting:(Meeting *)meeting withInvites:(NSArray *)invites withReasons:(NSArray *)reasons{

    [self createMeetingLocally:meeting withInvites:invites withReasons:reasons];
    [self createMeetingOnServer:meeting withInvites:invites withReasons:reasons];
    
}

- (NSManagedObject *) createMeetingLocally:(Meeting *)meeting withInvites:(NSArray *)invites withReasons:(NSArray *)reasons{
    
    
    // -------Meeting--------
    //
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *meeting_object = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"Meeting"
                                     inManagedObjectContext:context];
    [meeting_object setValue:meeting.name forKey:@"meeting_name"];
    [meeting_object setValue:meeting.description forKeyPath:@"meeting_description"];
    [meeting_object setValue:[NSNumber numberWithBool:meeting.isComeToMe] forKeyPath:@"is_ComeToMe"];
    [meeting_object setValue:[NSDate date] forKeyPath:@"created_date"];
    [meeting_object setValue:@NO forKey:@"is_old"];
    
    
    
    // -------Invites--------
    //
    if (invites != nil && invites.count > 0) {
        NSMutableSet *friendsSet = [[NSMutableSet alloc] init];
        for (Friend *f in invites) {
            NSManagedObject *newInvitee = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Person"
                                           inManagedObjectContext:context];
            [newInvitee setValue:f.name forKeyPath:@"name"];
            [newInvitee setValue:f.first_name forKeyPath:@"first_name"];
            [newInvitee setValue:f.last_name forKeyPath:@"last_name"];
            [newInvitee setValue:f.facebookID forKeyPath:@"facebook_id"];
            [friendsSet addObject:newInvitee];
        }
        
        // add invitees to meeting
        [meeting_object setValue:friendsSet forKey:@"invites"];
    }
    
    
    
    
    // -------Admin--------
    //
    NSManagedObject *meAdmin = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Person"
                                inManagedObjectContext:context];
    [meAdmin setValue:appDelegate.user.facebookID forKeyPath:@"facebook_id"];
    [meAdmin setValue:appDelegate.user.name forKeyPath:@"name"];
    [meAdmin setValue:appDelegate.user.first_name forKeyPath:@"first_name"];
    [meAdmin setValue:appDelegate.user.last_name forKeyPath:@"last_name"];
    
    // set self as admin
    [meAdmin setValue:meeting_object forKeyPath:@"administors"];
    [meeting_object setValue:meAdmin forKeyPath:@"admin"];
    
    
    
    
    
    // -------Reasons--------
    //
    if (reasons != nil && reasons.count > 0) {
        NSMutableSet *reasonsSet = [[NSMutableSet alloc] init];
        for (NSString *r in reasons) {
            NSManagedObject *newReason = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Meeting_reason"
                                          inManagedObjectContext:context];
            [newReason setValue:r forKey:@"reason"];
            [reasonsSet addObject:newReason];
        }
        [meeting_object setValue:reasonsSet forKeyPath:@"reasons"];
    }
    
    
    
    
    
    // -------Save Locally--------
    //
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [appDelegate saveContext];
    tempMeeting = meeting_object;
    
    return meeting_object;
}



- (void) createMeetingOnServer:(Meeting *)meeting withInvites:(NSArray *)invites withReasons:(NSArray *)reasons{
    
    
    
    // -------Save to Parse--------
    //
    PFObject *meetingParse = [PFObject objectWithClassName:@"Meeting"];
    meetingParse[@"name"] = meeting.name;
    meetingParse[@"admin_fb_id"] = [appDelegate user].facebookID;
    meetingParse[@"status"] = @"initial";
    [meetingParse addUniqueObjectsFromArray:reasons forKey:@"reasons"];
    meetingParse[@"comeToMe"] = [NSNumber numberWithBool:meeting.isComeToMe];
    meetingParse[@"meeting_description"] = meeting.description;
    
    NSMutableArray *fbIdArray = [[NSMutableArray alloc] init];
    for (Friend *f in invites) {
        [fbIdArray addObject:f.facebookID];
    }
    [meetingParse addUniqueObjectsFromArray:fbIdArray forKey:@"invites"];
    
    
    // -------Parse location--------
    //
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (!error) {
            if (meeting.isComeToMe) {
                meetingParse[@"final_meeting_location"] = geoPoint;
            }else{
                [meetingParse addUniqueObject:geoPoint forKey:@"meeter_locations"];
            }
        }
        
        // save
        [meetingParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                if (tempMeeting) {
                    [tempMeeting setValue:meetingParse.objectId forKey:@"parse_object_id"];
                }
                [appDelegate saveContext];
            }
        }];
        
    }];
    
    tempMeeting = nil;
}


// updating
/////////////////////////////////////////////////////////////////////////

- (void) updateMeetingObject:(NSManagedObject *)meetingObject withForeignMeeting:(PFObject *)foreignMeeting{
    
    [meetingObject setValue:[foreignMeeting objectForKey:@"name"] forKey:@"meeting_name"];
    [meetingObject setValue:[foreignMeeting objectForKey:@"description"] forKey:@"meeting_description"];
    [meetingObject setValue:[foreignMeeting mutableSetValueForKey:@"reasons"] forKey:@"reasons"];
    [meetingObject setValue:foreignMeeting.objectId forKey:@"parse_object_id"];
    [meetingObject setValue:[foreignMeeting mutableSetValueForKey:@"invites"] forKey:@"invites"];
    
    [appDelegate saveContext];
    
}

- (void) fetchMeetingUpdates{
    
    PFQuery *adminQuery = [PFQuery queryWithClassName:@"Meeting"];
    [adminQuery whereKey:@"admin_fb_id" equalTo:appDelegate.user.facebookID];
    
    PFQuery *invitedQuery = [PFQuery queryWithClassName:@"Meeting"];
    [invitedQuery whereKey:@"invites" equalTo:appDelegate.user.facebookID];
    
    PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:@[adminQuery, invitedQuery]];
    
    [compoundQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Found %lu meetings on server.", (unsigned long)objects.count);
            
            // load objects into core data
            for (PFObject *foreignMeeting in objects) {
                
                // query if meeting exists
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity =
                [NSEntityDescription entityForName:@"Meeting"
                            inManagedObjectContext:appDelegate.managedObjectContext];
                [request setEntity:entity];
                
                NSPredicate *predicate =
                [NSPredicate predicateWithFormat:@"parse_object_id == %@", foreignMeeting.objectId];
                [request setPredicate:predicate];
                
                NSError *error;
                NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
                
                NSManagedObject *localMeeting = nil;
                if (array != nil && array.count > 0) {
                    // update existing meeting
                    
                    localMeeting = [array objectAtIndex:0];
                    
                }else{
                    // create a new meeting locally
                    
                    // get info
                    Meeting *newMeeting = [[Meeting alloc] init];
                    newMeeting.name = [foreignMeeting valueForKey:@"name"];
                    newMeeting.description = [foreignMeeting valueForKey:@"description"];
                    
                    // get reasons
                    NSArray *reasonsArray = [foreignMeeting mutableArrayValueForKey:@"reasons"];
                    
                    // get invites
                    NSArray *invitesArray = [foreignMeeting mutableArrayValueForKey:@"invites"];
                    
                    // create
                    localMeeting = [self createMeetingLocally:newMeeting withInvites:invitesArray withReasons:reasonsArray];
                }
                
                // update
                [self updateMeetingObject:localMeeting withForeignMeeting:foreignMeeting];
            }
        }
    }];

    
}

// deleting
/////////////////////////////////////////////////////////////////////////

- (void) deleteMeetingWithId:(NSString *)parseObjectId{
    
    [self deleteMeetingLocallyWithId:parseObjectId];
    [self deleteMeetingOnServerWithId:parseObjectId];
    
}

- (void) deleteMeetingLocallyWithId:(NSString *)parseObjectId{
    
    // query meeting
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Meeting"
                inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"parse_object_id == %@", parseObjectId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    // delete it
    if (!error && array && array.count > 0) {
        NSManagedObject *o = [array objectAtIndex:0];
        [self deleteMeetingLocally:o];
    }else{
        NSLog(@"Error: %@", error);
    }
    
}

- (void) deleteMeetingOnServerWithId:(NSString *)parseObjectId{
    
    // delete on Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Meeting"];
    [query getObjectInBackgroundWithId:parseObjectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            [object deleteInBackground];
        }else{
            NSLog(@"Error: %@", error);
        }
    }];

}

- (void) deleteMeetingLocally:(NSManagedObject *)meetingObject{
    
    [appDelegate.managedObjectContext deleteObject:meetingObject];
    [appDelegate saveContext];
    
}

- (void) deleteMeetingSoft:(NSManagedObject *)meetingObject{
    
    // delete on parse
    [self deleteMeetingOnServerWithId:[meetingObject valueForKey:@"parse_object_id"]];
    
    
    // delete local relations
    //
    //  invites
    NSMutableSet *ppl = [meetingObject mutableSetValueForKey:@"invites"];
    for (NSManagedObject *p in ppl) {
        if ([p valueForKey:@"administors"] == nil) {
            [appDelegate.managedObjectContext deleteObject:p];
        }
    }
    [meetingObject setValue:nil forKey:@"invites"];
    //  reasons
    NSMutableSet *rsns = [meetingObject mutableSetValueForKey:@"reasons"];
    for (NSManagedObject *r in rsns) {
        [appDelegate.managedObjectContext deleteObject:r];
    }
    [meetingObject setValue:nil forKey:@"reasons"];
    
    // mark as old
    [meetingObject setValue:@YES forKey:@"is_old"];
    
    [appDelegate saveContext];
    
}

@end

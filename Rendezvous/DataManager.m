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

- (BOOL) createMeeting:(Meeting *)meeting withInvites:(NSArray *)invites withReasons:(NSArray *)reasons{
    
    if (invites && invites.count > 0 && ![[invites objectAtIndex:0] isKindOfClass:[Friend class]]) {
        NSLog(@"Error: Please pass in an array of types Friend.");
        return NO;
    }
    
    if (reasons && reasons.count > 0 && ![[reasons objectAtIndex:0] isKindOfClass:[NSString class]]) {
        NSLog(@"Error: Please pass in an array of types NSString.");
        return NO;
    }
    
    
    while (tempMeeting) {
        // do nothing :(
    }
    [self createMeetingLocally:meeting withInvites:invites withReasons:reasons];
    
    while (!tempMeeting) {
        // do nothing :(
    }
    [self createMeetingOnServer:meeting withInvites:invites withReasons:reasons];
    
    
    
    
    return YES;
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
    [meeting_object setValue:@1 forKey:@"num_responded"];
    [meeting_object setValue:@NO forKey:@"is_old"];
    [meeting_object setValue:@NO forKey:@"user_responded"];
    
    
    
    // -------Invites--------
    //
    NSMutableSet *friendsSet = [[NSMutableSet alloc] init];
    if (invites != nil && invites.count > 0) {
        
        for (Friend *f in invites) {
            
            // query if person exists
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity =
            [NSEntityDescription entityForName:@"Person"
                        inManagedObjectContext:appDelegate.managedObjectContext];
            [request setEntity:entity];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebook_id == %@", f.facebookID];
            [request setPredicate:predicate];
            
            NSError *error;
            NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
            
            NSManagedObject *localPerson = nil;
            if (array != nil && array.count > 0 && [[array objectAtIndex:0] valueForKey:@"meeting"] != nil) {
                // update existing person
                localPerson = [array objectAtIndex:0];
                
            }else{
                // create new person
                localPerson = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Person"
                               inManagedObjectContext:appDelegate.managedObjectContext];
                [friendsSet addObject:localPerson];
            }
            
            // update person info
            [localPerson setValue:f.facebookID
                           forKey:@"facebook_id"];
            [localPerson setValue:meeting_object
                           forKey:@"meeting"];
            [localPerson setValue:f.name
                           forKey:@"name"];
            
        }
        
    }
    
    // add invitees to meeting
    [meeting_object setValue:friendsSet forKey:@"invites"];
    
    
    
    
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
    
    NSLog(@"saved locally");
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
            
            [meetingParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    [tempMeeting setValue:meetingParse.objectId forKeyPath:@"parse_object_id"];
                    [appDelegate saveContext];
                }
            }];
            
        }else{
            NSLog(@"Location error: %@", error);
        }
        
    }];
    
    
    
    
    
}


// updating
/////////////////////////////////////////////////////////////////////////

- (void) updateMeetingObject:(NSManagedObject *)meetingObject withForeignMeeting:(PFObject *)foreignMeeting{
    
    [meetingObject setValue:[foreignMeeting objectForKey:@"name"] forKey:@"meeting_name"];
    [meetingObject setValue:[foreignMeeting objectForKey:@"description"] forKey:@"meeting_description"];
    [meetingObject setValue:foreignMeeting.objectId forKey:@"parse_object_id"];
    [meetingObject setValue:@NO forKey:@"user_responded"];
    
    // reasons
    //
    NSMutableSet *reasonsSet = [[NSMutableSet alloc] init];
    for (NSString *r in [foreignMeeting mutableSetValueForKey:@"reasons"]) {
        NSManagedObject *newReason = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Meeting_reason"
                                      inManagedObjectContext:appDelegate.managedObjectContext];
        [newReason setValue:r forKey:@"reason"];
        [reasonsSet addObject:newReason];
    }
    [meetingObject setValue:reasonsSet forKeyPath:@"reasons"];
    
    
    
    
    // People
    //
    // invites
    NSMutableSet *invitesSet = [meetingObject mutableSetValueForKey:@"invites"];
    if (!invitesSet) {
        invitesSet = [[NSMutableSet alloc] init];
    }
    [meetingObject setValue:invitesSet forKey:@"invites"];
    for (NSString *f in [foreignMeeting mutableSetValueForKey:@"invites"]) {
        
        
        // query if person exists
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Person"
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebook_id == '%@' AND meeting.parse_object_id == '%@'", f, foreignMeeting.objectId];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *localPerson = nil;
        if (array != nil && array.count > 0) {
            // update existing person
            
            NSLog(@"updating invite: %@", f);
            
            localPerson = [array objectAtIndex:0];
            
        }else{
            // create new person
            
            NSLog(@"adding invite: %@", f);
            
            localPerson = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Person"
                                           inManagedObjectContext:appDelegate.managedObjectContext];
            [invitesSet addObject:localPerson];
        }
        
        
        

        // update person info
        [localPerson setValue:f forKey:@"facebook_id"];
        [localPerson setValue:meetingObject forKey:@"meeting"];
        
    }
    
    //
    // accepted
    NSMutableSet *acceptedSet = [meetingObject mutableSetValueForKey:@"accepted"];
    if (!acceptedSet) {
        acceptedSet = [[NSMutableSet alloc] init];
        [meetingObject setValue:acceptedSet forKey:@"accepted"];
    }
    
    for (NSString *f in [foreignMeeting mutableSetValueForKey:@"fb_ids_accepted_users"]) {
        
        if ([f isEqualToString:appDelegate.user.facebookID]) {
            [meetingObject setValue:@YES forKey:@"user_responded"];
        }
        
        // query if person exists
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Person"
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebook_id == '%@' AND meeting.parse_object_id == '%@'", f, foreignMeeting.objectId];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *localPerson = nil;
        if (array && array.count > 0) {
            // update existing person
            
            localPerson = [array objectAtIndex:0];
            
        }else{
            // create new person
            
            localPerson = [NSEntityDescription
                           insertNewObjectForEntityForName:@"Person"
                           inManagedObjectContext:appDelegate.managedObjectContext];
            [acceptedSet addObject:localPerson];
        }
        
        // update person info
        [localPerson setValue:f forKey:@"facebook_id"];
        [localPerson setValue:meetingObject forKey:@"accepted_meeting"];
        
    }

    
    
    
    //
    // declined
    NSMutableSet *declinedSet = [meetingObject mutableSetValueForKey:@"declined"];
    if (!declinedSet) {
        declinedSet = [[NSMutableSet alloc] init];
        [meetingObject setValue:declinedSet forKey:@"declined"];
    }
    
    for (NSString *f in [foreignMeeting mutableSetValueForKey:@"fb_ids_accepted_users"]) {
        
        if ([f isEqualToString:appDelegate.user.facebookID]) {
            [meetingObject setValue:@YES forKey:@"user_responded"];
        }
        
        // query if person exists
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Person"
                    inManagedObjectContext:appDelegate.managedObjectContext];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebook_id == '%@' AND meeting.parse_object_id == '%@'", f, foreignMeeting.objectId];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *localPerson = nil;
        if (array && array.count > 0) {
            // update existing person
            
            localPerson = [array objectAtIndex:0];
            
        }else{
            // create new person
            
            localPerson = [NSEntityDescription
                           insertNewObjectForEntityForName:@"Person"
                           inManagedObjectContext:appDelegate.managedObjectContext];
            [acceptedSet addObject:localPerson];
        }
        
        // update person info
        [localPerson setValue:f forKey:@"facebook_id"];
        [localPerson setValue:meetingObject forKey:@"declined_meeting"];
        
    }
    
    
    //
    // admin
    
    // query if person exists
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Person"
                inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"facebook_id == '%@' AND meeting.parse_object_id == '%@'", [foreignMeeting
                                                                         valueForKey:@"admin_fb_id"], foreignMeeting.objectId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    NSManagedObject *localAdmin = nil;
    if (array && array.count > 0 && [[array objectAtIndex:0] valueForKey:@"administors"] != nil) {
        // update existing person
        
        localAdmin = [array objectAtIndex:0];
        
    }else{
        // create new person & attach them
        
        localAdmin = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Person"
                       inManagedObjectContext:appDelegate.managedObjectContext];
        
    }
    
    if ([[foreignMeeting valueForKey:@"admin_fb_id"] isEqualToString:appDelegate.user.facebookID]) {
        [meetingObject setValue:@YES forKey:@"user_responded"];
    }
    
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"facebook_id" equalTo:[foreignMeeting valueForKey:@"admin_fb_id"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Do something with the found objects
            for (PFObject *object in objects) {
                [localAdmin setValue:[object valueForKey:@"name"] forKey:@"name"];
                NSLog(@"admin name: %@", [object valueForKey:@"name"]);
                [appDelegate saveContext];
                [((HomeViewController *)appDelegate.home) reloadMeetings];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // update person info
    [meetingObject setValue:localAdmin forKey:@"admin"];
    [localAdmin setValue:[foreignMeeting valueForKey:@"admin_fb_id"] forKey:@"facebook_id"];
    [localAdmin setValue:meetingObject forKey:@"administors"];

    
    
    // update some meeting info
    [meetingObject setValue:@NO forKey:@"is_old"];
    [meetingObject setValue:[foreignMeeting valueForKey:@"num_responded"] forKey:@"num_responded"];
    [meetingObject setValue:[foreignMeeting valueForKey:@"status"] forKey:@"status"];
    
    if ([appDelegate.user.facebookID isEqualToString:[foreignMeeting valueForKey:@"admin_fb_id"]]) {
        
    }
    
    NSLog(@"set status: %@", [foreignMeeting valueForKey:@"status"]);
    [((HomeViewController *)appDelegate.home) reloadMeetings];
    
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
            
            // mark everything as old
            // query local
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription
                                           entityForName:@"Meeting"
                                           inManagedObjectContext:appDelegate.managedObjectContext];
            [request setEntity:entity];
            
            /*
             NSPredicate *predicate =
             [NSPredicate predicateWithFormat:@"is_old == %@", @NO];
             [request setPredicate:predicate];
             */
            
            NSError *error;
            NSArray *resultsArray = [appDelegate.managedObjectContext
                                     executeFetchRequest:request error:&error];
            if (resultsArray != nil && resultsArray.count > 0) {
                // delete
                for (NSManagedObject *o in resultsArray) {
                    [o setValue:@YES forKey:@"is_old"];
                }
                
                [appDelegate saveContext];
            }
            
            
            
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
                    NSArray *reasonsArray = [[foreignMeeting mutableArrayValueForKey:@"reasons"] copy];;
                    
                    // get invites
                    NSArray *invitesArray = [[foreignMeeting mutableArrayValueForKey:@"invites"] copy];
                    NSMutableArray *friendsArray = [[NSMutableArray alloc] init];
                    for (NSString *invite in invitesArray) {
                        Friend *f = [[Friend alloc] init];
                        f.facebookID = invite;
                        [friendsArray addObject:f];
                    }
                    
                    // create
                    localMeeting = [self createMeetingLocally:newMeeting withInvites:friendsArray withReasons:reasonsArray];
                }
                
                // update
                [self updateMeetingObject:localMeeting withForeignMeeting:foreignMeeting];
            }
            
        }else{
            NSLog(@"Error pulling updates: %@", error);
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
    
    NSLog(@"meeting to delete: %@", [meetingObject valueForKey:@"parse_object_id"]);
    
    // delete on parse
    [self deleteMeetingOnServerWithId:[meetingObject valueForKey:@"parse_object_id"]];
    
    NSLog(@"deleted on Parse");
    
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
    NSLog(@"deleted locally");
    
}

@end

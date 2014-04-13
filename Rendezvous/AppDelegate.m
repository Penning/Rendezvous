//
//  AppDelegate.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AcceptDeclineController.h"
#import "LocationViewController.h"
#import "DataManager.h"
#import "FinalViewController.h"
#import "LocationSuggestionsLookup.h"
#import "Friend.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate{
    int lastId;
    PFObject *notificationMeeting;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize user = _user;
@synthesize home = _home;
@synthesize contacts = _contacts;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    lastId = 0;
    
    _user = [[CurrentUser alloc] init];
    // [_user getMyInformation];

    //Parse setup
    [Parse setApplicationId:@"aZPN4SiTApTkjRRj6heYGQ6Qkig6rVslPAD8hvyf"
                  clientKey:@"jalcrCGQosyYPapT1QgD5B4dUH5qjlf9mIpFe61O"];

    //Parse Analytics
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    [PFFacebookUtils initializeFacebook];

//    if (!FBSession.activeSession.isOpen) {
//        [FBSession openActiveSessionWithAllowLoginUI: YES];
//    }

    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)debugAlert:(NSObject *)message{
    
    [[[UIAlertView alloc] initWithTitle:@"Debug"
                                message:[NSString stringWithFormat:@"%@", message]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];
}


- (void)handleNotification:(NSDictionary *)payload {
    
    // [PFPush handlePush:payload];
    // [self debugAlert:payload];
    
    
    // Create empty meeting object
    NSString *meetingId = [payload objectForKey:@"meetingId"];
    
    if (meetingId) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Meeting"];
        [query getObjectInBackgroundWithId:meetingId block:^(PFObject *object, NSError *error) {
            
            if (!error && [PFUser currentUser]) {
                
                // set meeting object
                notificationMeeting = object;
                
                // alert
                if ([[payload objectForKey:@"type"] isEqualToString:@"invite"]) {
                    // invite
                    
                    [[[UIAlertView alloc] initWithTitle:@"Rendezvous recieved!"
                                                message:[payload valueForKeyPath:@"aps.alert"]
                                               delegate:self
                                      cancelButtonTitle:@"Later"
                                      otherButtonTitles:@"RSVP", nil] show];
                    
                }else if ([[payload objectForKey:@"type"] isEqualToString:@"choose_location"]){
                    // choose location
                    
                    [[[UIAlertView alloc] initWithTitle:@"Meeting closed!"
                                                message:[payload valueForKeyPath:@"aps.alert"]
                                               delegate:self
                                      cancelButtonTitle:@"Later"
                                      otherButtonTitles:@"Choose Location", nil] show];
                    
                }else if ([[payload objectForKey:@"type"] isEqualToString:@"final"]){
                    // final
                    
                    [[[UIAlertView alloc] initWithTitle:@"Rendezvous!"
                                                message:[payload valueForKeyPath:@"aps.alert"]
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"View Location", nil] show];
                    
                }else{
                    [self debugAlert:payload];
                }
                
            }else{
                NSLog(@"Error: %@", error);
            }
            

        }];

        
        
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // later; ignore
    }else if (buttonIndex == 1){
        // act
        
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"RSVP"]) {
            // accept/decline
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
            AcceptDeclineController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"accept_decline"];
            
            [viewController setParseMeeting:notificationMeeting];
            
            [((UINavigationController *)self.window.rootViewController)
             pushViewController:viewController
             animated:YES];
        }else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Location"]){
            // choose location
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
            LocationViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"location_view"];
            LocationSuggestionsLookup *locationSuggestionsLookup = [[LocationSuggestionsLookup alloc] init];
            locationSuggestionsLookup.locationViewController = vc;
            NSLog(@"Meeting Selected: %@", notificationMeeting);
            [locationSuggestionsLookup getSuggestions:[[Meeting alloc] fromPFObject:notificationMeeting]];
            
            [((UINavigationController *)self.window.rootViewController)
             pushViewController:vc
             animated:YES];
        }else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Location"]){
            // view location
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
            FinalViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"final_view"];
            
            [viewController setParseMeeting:notificationMeeting];
            
            [((UINavigationController *)self.window.rootViewController)
             pushViewController:viewController
             animated:YES];
        }
        
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
    [[PFUser currentUser] setObject:[[PFInstallation currentInstallation] deviceToken] forKey:@"device_token"];
    [[PFUser currentUser] saveInBackground];
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    [self handleNotification:userInfo];
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_user getMyInformation];
    
    // Facebook SDK
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    
    // reset badge count
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

    if(self.user.friends.count == 0) {
        //Query all Parse users
        self.user.friends = [[NSMutableArray alloc] init];
        self.user.friendsWithApp = [[NSMutableArray alloc] init];
        self.user.friendsWithoutApp = [[NSMutableArray alloc] init];

        PFQuery *query = [PFUser query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture"];

                [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if(!error) {
                        NSArray *data = [result objectForKey:@"data"];

                        for (FBGraphObject<FBGraphUser> *fbfriend in data) {
                            Friend *friend = [[Friend alloc] initWithObject:fbfriend];
                            [self.user.friends addObject:friend];

                            for(PFUser *user in objects) {
                                if([[user valueForKey:@"name"] isEqualToString:friend.name]) {
                                    if(![self.user.friendsWithApp containsObject:friend]) {
                                        NSLog(@"Adding %@", friend.name);
                                        [self.user.friendsWithApp addObject:friend];
                                    }
                                } else {
                                    if(![self.user.friendsWithoutApp containsObject:friend] && ![self.user.friendsWithApp containsObject:friend]) {
                                        [self.user.friendsWithoutApp addObject:friend];
                                    }
                                }
                            }
                        }

                        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

                        NSArray *temp = [self.user.friendsWithApp sortedArrayUsingDescriptors:sortDescriptors];
                        [self.user.friendsWithApp removeAllObjects];
                        [self.user.friendsWithApp addObjectsFromArray:temp];

                        NSArray *temp2 = [self.user.friendsWithoutApp sortedArrayUsingDescriptors:sortDescriptors];
                        [self.user.friendsWithoutApp removeAllObjects];
                        [self.user.friendsWithoutApp addObjectsFromArray:temp2];

                        NSLog(@"Found %lu friends!", (unsigned long)self.user.friends.count);
                        [((ContactsViewController *)_contacts).activityIndicator stopAnimating];
                        [((ContactsViewController *)_contacts).tableView reloadData];
                    } else {
                        NSLog(@"Facebook Error: %@", error);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Cannot reach Facebook servers. You will not be able to create a new meeting." delegate:self cancelButtonTitle:@"I Understand" otherButtonTitles:nil];
                        [alert show];
                    }
                }];
            } else {
                NSLog(@"Parse Error: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parse Error" message:@"Cannot reach Parse servers. You will not be able to do anything." delegate:self cancelButtonTitle:@"I Understand" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }

    // debug
    // [self debugNotifications];
    
}

- (void)debugNotifications {
    NSDictionary *inner = [[NSDictionary alloc]
                           initWithObjects:@[@"debugging..."]
                           forKeys:@[@"alert"]];
    
    NSDictionary *outer = [[NSDictionary alloc]
                           initWithObjects:@[inner, @"choose_location", @"L4TzYHCSB0"]
                           forKeys:@[@"aps", @"type", @"meetingId"]];
    
    
    [self handleNotification:outer];
}

- (void)getMeetingUpdates{
    NSLog(@"fetching updates");
    
    DataManager *dm = [[DataManager alloc] init];
    [dm fetchMeetingUpdates];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[PFFacebookUtils session] close];
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            [((HomeViewController *)_home) reloadMeetings];
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Rendezvous" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Rendezvous.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

@end

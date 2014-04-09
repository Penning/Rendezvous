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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate{
    int lastId;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize user = _user;
@synthesize home = _home;

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
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (notificationPayload != nil && notificationPayload.count > 0) {
        // Create a pointer to the Photo object
        NSString *meetingId = [notificationPayload objectForKey:@"meetinID"];
        
        if (meetingId) {
            PFObject *targetMeeting = [PFObject objectWithoutDataWithClassName:@"Meeting"
                                                                      objectId:meetingId];
            
            // Fetch meeting object
            [targetMeeting fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (!error && [PFUser currentUser]) {
                    if ([_user.facebookID isEqualToString:[object valueForKey:@"admin_fb_id"]]) {
                        // user is admin. segue to close meeting screen
                        
                        LocationViewController *viewController = [[LocationViewController alloc] initWithMeeting:object];
                        [((UINavigationController *)self.window.rootViewController) pushViewController:viewController animated:YES];
                    }else{
                        // user is not admin. segue to accept/decline screen
                        
                        AcceptDeclineController *viewController = [[AcceptDeclineController alloc] initWithMeeting:object];
                        [((UINavigationController *)self.window.rootViewController) pushViewController:viewController animated:YES];
                    }
                }else if (error){
                    NSLog(@"Error: %@", error);
                }else{
                    NSLog(@"Error: no user logged in.");
                }
                
            }];
        }
        
    }
    



    return YES;
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
    [[PFUser currentUser] setObject:[[PFInstallation currentInstallation] deviceToken] forKey:@"device_token"];
    [[PFUser currentUser] saveInBackground];
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    // Create empty meeting object
    NSString *meetingId = [userInfo objectForKey:@"meetingID"];
    
    if (meetingId) {
        PFObject *targetMeeting = [PFObject objectWithoutDataWithClassName:@"Meeting"
                                                                  objectId:meetingId];
        
        // Fetch meeting object
        [targetMeeting fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            // Show photo view controller
            if (error) {
                NSLog(@"Error: %@", error);
            } else if ([PFUser currentUser]) {
                
                if ([_user.facebookID isEqualToString:[object valueForKey:@"admin_fb_id"]]) {
                    // user is admin. segue to close meeting screen
                    
                    LocationViewController *viewController = [[LocationViewController alloc] initWithMeeting:object];
                    [((UINavigationController *)self.window.rootViewController) pushViewController:viewController animated:YES];
                }else{
                    // user is not admin. segue to accept/decline screen
                    
                    AcceptDeclineController *viewController = [[AcceptDeclineController alloc] initWithMeeting:object];
                    [((UINavigationController *)self.window.rootViewController) pushViewController:viewController animated:YES];
                }
                
                
            } else {
                NSLog(@"Error: no user logged in.");
            }
        }];
    }
    
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

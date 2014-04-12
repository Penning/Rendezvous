//
//  AppDelegate.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentUser.h"
#import "HomeViewController.h"
#import "ContactsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


// Current User
@property (readonly, strong, nonatomic) CurrentUser *user;

// home view controller
@property (strong, nonatomic) UIViewController *home;

// contacts view controller
@property (strong, nonatomic) UITableViewController *contacts;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)getMeetingUpdates;

@end

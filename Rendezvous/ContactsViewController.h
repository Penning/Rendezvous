//
//  ContactsViewController.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ContactsViewController : UITableViewController

//@property (strong, nonatomic) NSArray *friends;
//@property (strong, nonatomic) NSMutableArray *friendsWithApp;
//@property (strong, nonatomic) NSMutableArray *friendsWithoutApp;
@property (strong, nonatomic) NSMutableArray *meeters;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *meetingNameBarBtn;

@property (strong, nonatomic) NSManagedObject *meetingObject;

@end

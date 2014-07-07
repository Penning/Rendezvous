//
//  ContactsViewController.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppDelegate.h"

@interface ContactsViewController : UITableViewController <UITabBarDelegate, MFMailComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *meeters;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *meetingNameBarBtn;

@property (strong, nonatomic) NSManagedObject *meetingObject;

@property (strong, nonatomic) IBOutlet UITabBar *contactsFilterBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *contactsItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *addressItem;

@property NSString * addressBookNum;

@end

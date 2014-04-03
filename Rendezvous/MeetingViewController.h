//
//  MeetingViewController.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meeting.h"


@interface MeetingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextView *detailsTextView;

@property (strong, nonatomic) IBOutlet UISwitch *comeToMeSwitch;
@property (strong, nonatomic) IBOutlet UIButton *sendContactsButton;
@property (strong, nonatomic) IBOutlet UILabel *numMeetersLabel;

@property (strong, nonatomic) NSArray *meeters;
@property (strong, nonatomic) NSArray *reasons;
@property (strong, nonatomic) Meeting *meeting;

@property (strong, nonatomic) NSManagedObject *meetingObject;

- (void)initFromHome;
- (void)initFromContacts;

@end

//
//  MeetingViewController.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextView *detailsTextView;

@property (strong, nonatomic) IBOutlet UISwitch *comeToMeSwitch;
@property (strong, nonatomic) IBOutlet UIButton *sendContactsButton;

- (void)initFromHome;
- (void)initFromContacts;

@end

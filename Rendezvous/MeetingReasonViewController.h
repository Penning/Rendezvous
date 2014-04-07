//
//  MeetingReasonViewController.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/2/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetingReasonViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *meeters;
@property (strong, nonatomic) IBOutlet UIButton *food;
@property (strong, nonatomic) IBOutlet UIButton *drinks;
@property (strong, nonatomic) IBOutlet UIButton *coffee;
@property (strong, nonatomic) IBOutlet UIButton *entertainment;
@property (strong, nonatomic) IBOutlet UIButton *shopping;
@property (strong, nonatomic) IBOutlet UIButton *arts;
@property (strong, nonatomic) IBOutlet UIButton *studying;
@property (strong, nonatomic) IBOutlet UIButton *music;

@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSString *meetingName;

- (IBAction)foodSelected:(id)sender;
- (IBAction)drinksSelected:(id)sender;
- (IBAction)coffeeSelected:(id)sender;
- (IBAction)entertainmentSelected:(id)sender;
- (IBAction)shoppingSelected:(id)sender;
- (IBAction)artsSelected:(id)sender;
- (IBAction)studyingSelected:(id)sender;
- (IBAction)musicSelected:(id)sender;
- (IBAction)sendMeeting:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *meetingNameBarButtonItem;

- (void)initForSend;

//Back to contacts
- (IBAction)back:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *okToolbarBtn;

@end

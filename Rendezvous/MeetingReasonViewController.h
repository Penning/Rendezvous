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

- (IBAction)foodSelected:(id)sender;
- (IBAction)drinksSelected:(id)sender;
- (IBAction)coffeeSelected:(id)sender;
- (IBAction)entertainmentSelected:(id)sender;
- (IBAction)shoppingSelected:(id)sender;
- (IBAction)artsSelected:(id)sender;
- (IBAction)studyingSelected:(id)sender;
- (IBAction)musicSelected:(id)sender;
- (IBAction)sendMeeting:(id)sender;

@end

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


@property (weak, nonatomic) IBOutlet UILabel *meetingTitleLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBtn;
@property (strong, nonatomic) NSManagedObject *meetingObject;
@property (weak, nonatomic) IBOutlet UILabel *meetingCreatedLabel;

- (void)initFromHome;
- (void)initFromContacts;


@end

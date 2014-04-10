//
//  AcceptDeclineController.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/7/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Meeting.h"

@interface AcceptDeclineController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *meetingTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *meetingDescriptionTextView;


@property (strong, nonatomic) NSManagedObject *localMeeting;
@property (strong, nonatomic) PFObject *parseMeeting;

@end

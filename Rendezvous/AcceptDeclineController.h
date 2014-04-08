//
//  AcceptDeclineController.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/7/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AcceptDeclineController : UIViewController

- (AcceptDeclineController *)initWithMeeting:(PFObject *)meeting;

@end

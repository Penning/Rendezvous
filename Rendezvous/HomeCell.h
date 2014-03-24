//
//  HomeCell.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/23/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *meetingName;
@property (strong, nonatomic) IBOutlet UILabel *meetingAdmin;
@property (strong, nonatomic) IBOutlet UILabel *acceptedLabel;
@property (strong, nonatomic) UIViewController *parentController;

- (void)initializeGenstureRecognizer;

@end

//
//  HomeCell.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/23/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCell : UITableViewCell

// linked
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *adminImageView;

// internal
@property (strong, nonatomic) UIViewController *parentController;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSString *adminFbId;

- (void)initializeGestureRecognizer;

@end

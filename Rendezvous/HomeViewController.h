//
//  HomeViewController.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCell.h"

@interface HomeViewController : UIViewController

- (void)cellDoubleTapped:(HomeCell *)sender;
- (void)cellSingleTapped:(HomeCell *)sender;

@end

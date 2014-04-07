//
//  LoginViewController.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/24/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *loggedin_label;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profile_picture;
@property (strong, nonatomic) IBOutlet UIImageView *logo;

- (IBAction)login:(id)sender;
- (void) logoutAction;
- (IBAction)logout:(id)sender;

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

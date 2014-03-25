//
//  LoginViewController.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/24/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)login:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

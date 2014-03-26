//
//  LoginViewController.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/24/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "HomeViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_profile_picture setHidden:YES];
    [_loggedin_label setHidden:YES];
    [_logo setHidden:NO];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser]) {
        [self displayUserInfo];
    } else {
        _loginButton.titleLabel.text = @"Log in";
        [_profile_picture setHidden:YES];
        [_loggedin_label setHidden:YES];
        [_logo setHidden:NO];
        [_loginButton setHidden:NO];
        [_logoutButton setHidden:YES];
    }
}

- (void)displayUserInfo {
    //Display UI
//    _loginButton.titleLabel.text = @"Log out";

    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];

    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;

            NSString *name = userData[@"name"];
            _loggedin_label.text = [NSString stringWithFormat:@"%@", name];

            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

            // Download the user's facebook profile picture
            _imageData = [[NSMutableData alloc] init]; // the data will be loaded in here

            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }];

    //Display UI
    [_profile_picture setHidden:NO];
    [_loggedin_label setHidden:NO];
    [_loginButton setHidden:YES];
    [_logoutButton setHidden:NO];
    [_logo setHidden:YES];
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_imageData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    _profile_picture.image = [UIImage imageWithData:_imageData];

    _profile_picture.layer.cornerRadius = 64.0f;
    _profile_picture.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)login:(id)sender {
    if(![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // The permissions requested from the user
        NSArray *permissionsArray = @[ @"basic_info", @"user_location", @"user_groups", @"user_relationships"];

        // Login PFUser using Facebook
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            [_activityIndicator stopAnimating]; // Hide loading indicator

            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else {
                    NSLog(@"Uh oh. An error occurred: %@", error);
                }
            } else if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self performSegueWithIdentifier:@"login_segue" sender:self];
            } else {
                NSLog(@"User with facebook logged in!");
                [self performSegueWithIdentifier:@"login_segue" sender:self];
            }
        }];
        [self displayUserInfo];
//        [_loginButton setTitle: @"Log out" forState: UIControlStateApplication];
    }
}

- (IBAction)logout:(id)sender {
    [PFUser logOut]; // Log out
    _loginButton.titleLabel.text = @"Log in";
    [_profile_picture setHidden:YES];
    [_loggedin_label setHidden:YES];
    [_logo setHidden:NO];
    [_loginButton setHidden:NO];
    [_logoutButton setHidden:YES];
}

@end

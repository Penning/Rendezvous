//
//  MeetingReasonViewController.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/2/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "MeetingReasonViewController.h"
#import "MeetingViewController.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "DataManager.h"

#import <Parse/Parse.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.3]

@interface MeetingReasonViewController ()

@end

@implementation MeetingReasonViewController {
    UIAlertView *alert;
    NSMutableArray *reasons;
    BOOL okShouldBeSend;
}

@synthesize meeters;
@synthesize meetingName = _meetingName;

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
    
    reasons = [[NSMutableArray alloc] init];
    
    [self.meetingNameBarButtonItem setTitle:_meetingName];
}

- (void)viewWillAppear:(BOOL)animated{
    
    // clear navbar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initForSend{
    okShouldBeSend = YES;
}

#pragma mark - Navigation




- (IBAction)foodSelected:(id)sender {
    if(![reasons containsObject:@"restaurants"]) {
        [reasons addObject:@"restaurants"];
        [_food setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"restaurants"];
        [_food setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)drinksSelected:(id)sender {
    if(![reasons containsObject:@"nightlife"]) {
        [reasons addObject:@"nightlife"];
        [_drinks setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"nightlife"];
        [_drinks setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)coffeeSelected:(id)sender {
    if(![reasons containsObject:@"coffee"]) {
        [reasons addObject:@"coffee"];
        [_coffee setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"coffee"];
        [_coffee setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)entertainmentSelected:(id)sender {
    if(![reasons containsObject:@"movietheaters"]) {
        [reasons addObject:@"movietheaters"];
        [_entertainment setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"movietheaters"];
        [_entertainment setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)shoppingSelected:(id)sender {
    if(![reasons containsObject:@"shopping"]) {
        [reasons addObject:@"shopping"];
        [_shopping setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"shopping"];
        [_shopping setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)artsSelected:(id)sender {
    if(![reasons containsObject:@"arts"]) {
        [reasons addObject:@"arts"];
        [_arts setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"arts"];
        [_arts setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)studyingSelected:(id)sender {
    if(![reasons containsObject:@"libraries"]) {
        [reasons addObject:@"libraries"];
        [_studying setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"libraries"];
        [_studying setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)musicSelected:(id)sender {
    if(![reasons containsObject:@"musicvenues"]) {
        [reasons addObject:@"musicvenues"];
        [_music setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"musicvenues"];
        [_music setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}


- (IBAction)nameBtnHit:(id)sender {
    
    alert = [[UIAlertView alloc] initWithTitle:@"Edit Name"
                                       message:@"Enter the new meeting name"
                                      delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setReturnKeyType:UIReturnKeyDone];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)alertTextField {
        
    [alert dismissWithClickedButtonIndex:1 animated:YES];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // cancel
    }else if(buttonIndex == 1){
        // change name
        self.meetingName = [alert textFieldAtIndex:0].text;
        [self.meetingNameBarButtonItem setTitle:self.meetingName];
    }
}


- (IBAction)okToolbarBtnHit:(id)sender {
    
    Meeting *newMeeting = [[Meeting alloc] init];
    newMeeting.name = self.meetingName;
    newMeeting.description = @"";
    [newMeeting setComeToMe:self.myLocationSwitch.isOn];
    
    DataManager *dm = [[DataManager alloc] init];
    [dm createMeeting:newMeeting withInvites:meeters withReasons:reasons];
    
    
    // unwind segue to home
    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [self.navigationController popToViewController:appDelegate.home animated:YES];
        

}

@end

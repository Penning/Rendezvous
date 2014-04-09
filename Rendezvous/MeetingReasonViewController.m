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
    
    if (okShouldBeSend) {
        [self.okToolbarBtn setTitle:@"Send"];
    }else{
        [self.okToolbarBtn setTitle:@"OK"];
    }
    
    [self.meetingNameBarButtonItem setTitle:_meetingName];
}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
//    [self.navigationController setToolbarHidden:NO animated:animated];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"contacts_details_segue"]) {
        MeetingViewController *vc = (MeetingViewController *)[segue destinationViewController];
        [vc initFromContacts];
        [vc setReasons:reasons];
        [vc setMeeters:meeters];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


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
    if(![reasons containsObject:@"bars"]) {
        [reasons addObject:@"bars"];
        [_drinks setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"bars"];
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


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okToolbarBtnHit:(id)sender {
    if (okShouldBeSend) {
        
        Meeting *newMeeting = [[Meeting alloc] init];
        newMeeting.name = self.meetingName;
        newMeeting.description = @"";
        [newMeeting setComeToMe:NO];
        
        DataManager *dm = [[DataManager alloc] init];
        [dm createMeeting:newMeeting withInvites:meeters withReasons:reasons];
        
        
        // unwind segue to home
        AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        [self.navigationController popToViewController:appDelegate.home animated:YES];
        
    }else{
        [self performSegueWithIdentifier:@"contacts_details_segue" sender:self];
    }
}

@end

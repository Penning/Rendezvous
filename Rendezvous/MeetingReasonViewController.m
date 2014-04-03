//
//  MeetingReasonViewController.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/2/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "MeetingReasonViewController.h"
#import "MeetingViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.3]

@interface MeetingReasonViewController ()

@end

@implementation MeetingReasonViewController {
    NSMutableArray *reasons;
}

@synthesize meeters;

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
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    reasons = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    // [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
//    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(![reasons containsObject:@"food"]) {
        [reasons addObject:@"food"];
        [_food setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"food"];
        [_food setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)drinksSelected:(id)sender {
    if(![reasons containsObject:@"drinks"]) {
        [reasons addObject:@"drinks"];
        [_drinks setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"drinks"];
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
    if(![reasons containsObject:@"entertainment"]) {
        [reasons addObject:@"entertainment"];
        [_entertainment setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"entertainment"];
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
    if(![reasons containsObject:@"studying"]) {
        [reasons addObject:@"studying"];
        [_studying setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"studying"];
        [_studying setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)musicSelected:(id)sender {
    if(![reasons containsObject:@"music"]) {
        [reasons addObject:@"music"];
        [_music setBackgroundColor:UIColorFromRGB(0x000000)];
    }
    else {
        [reasons removeObject:@"music"];
        [_music setBackgroundColor:UIColorFromRGB(0xffffff)];
    }
}

- (IBAction)sendMeeting:(id)sender {
    //Send meeting to Parse
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

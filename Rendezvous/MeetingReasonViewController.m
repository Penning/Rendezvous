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

- (IBAction)okToolbarBtnHit:(id)sender {
    if (okShouldBeSend) {
        
        
        // __Core Data stuff ahead__
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // create meeting
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *meeting_object = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Meeting"
                                           inManagedObjectContext:context];
        [meeting_object setValue:self.meetingName forKey:@"meeting_name"];
        [meeting_object setValue:@"" forKeyPath:@"meeting_description"];
        
        [meeting_object setValue:@NO forKeyPath:@"is_ComeToMe"];
        [meeting_object setValue:[NSDate date] forKeyPath:@"created_date"];
        [meeting_object setValue:@NO forKey:@"is_old"];
        
        // create friends
        NSMutableSet *friendsSet = [[NSMutableSet alloc] init];
        for (Friend *f in self.meeters) {
            NSManagedObject *newInvitee = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Person"
                                           inManagedObjectContext:context];
            [newInvitee setValue:f.name forKeyPath:@"name"];
            [newInvitee setValue:f.first_name forKeyPath:@"first_name"];
            [newInvitee setValue:f.last_name forKeyPath:@"last_name"];
            [newInvitee setValue:f.facebookID forKeyPath:@"facebook_id"];
            [friendsSet addObject:newInvitee];
        }
        
        // add invitees to meeting
        [meeting_object setValue:friendsSet forKey:@"invites"];
        
        // create Person object for self
        NSManagedObject *meAdmin = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Person"
                                    inManagedObjectContext:context];
        [meAdmin setValue:appDelegate.user.facebookID forKeyPath:@"facebook_id"];
        [meAdmin setValue:appDelegate.user.name forKeyPath:@"name"];
        [meAdmin setValue:appDelegate.user.first_name forKeyPath:@"first_name"];
        [meAdmin setValue:appDelegate.user.last_name forKeyPath:@"last_name"];
        
        // set self as admin
        [meAdmin setValue:meeting_object forKeyPath:@"administors"];
        [meeting_object setValue:meAdmin forKeyPath:@"admin"];
        
        // add reasons
        NSMutableSet *reasonsSet = [[NSMutableSet alloc] init];
        for (NSString *r in reasons) {
            NSManagedObject *newReason = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Meeting_reason"
                                          inManagedObjectContext:context];
            [newReason setValue:r forKey:@"reason"];
            [reasonsSet addObject:newReason];
        }
        [meeting_object setValue:reasonsSet forKeyPath:@"reasons"];
        
        // save it!
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
        
        
        // save to Parse
        PFObject *meetingParse = [PFObject objectWithClassName:@"Meeting"];
        meetingParse[@"name"] = self.meetingName;
        meetingParse[@"admin_fb_id"] = [appDelegate user].facebookID;
        meetingParse[@"status"] = @"initial";
        [meetingParse addUniqueObjectsFromArray:reasons forKey:@"reasons"];
        meetingParse[@"comeToMe"] = @NO;
        meetingParse[@"meeting_description"] = @"";
        
        NSMutableArray *fbIdArray = [[NSMutableArray alloc] init];
        for (Friend *f in meeters) {
            [fbIdArray addObject:f.facebookID];
        }
        [meetingParse addUniqueObjectsFromArray:fbIdArray forKey:@"invites"];
        
        
        [meetingParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [meeting_object setValue:meetingParse.objectId forKey:@"parse_object_id"];
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
            }
        }];
        
        // TODO: send invites
        
        
        // unwind segue to home
        [self.navigationController popToViewController:appDelegate.home animated:YES];
        
    }else{
        [self performSegueWithIdentifier:@"contacts_details_segue" sender:self];
    }
}

@end

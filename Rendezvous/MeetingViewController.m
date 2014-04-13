//
//  MeetingViewController.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "MeetingViewController.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "ContactsViewController.h"
#import "DataManager.h"
#import "GuestListController.h"

@interface MeetingViewController (){
    BOOL home;
}

@end



@implementation MeetingViewController {
    NSString *tempName;
}

@synthesize meetingObject = _meetingObject;

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
    
    
    
}

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self.navigationController.navigationBar.topItem setTitle:[_meetingObject valueForKey:@"meeting_name"]];
    
    
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        [textField resignFirstResponder];
        return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initFromHome {
    home = true;
}

- (void)initFromContacts{
    home = false;
}


- (IBAction)deleteBtnHit:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Cancel Meeting"
                           message:@"Are you sure you want to cancel this meeting?"
                           delegate:self
                           cancelButtonTitle:@"No"
                           otherButtonTitles:@"Yes", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

// alertview handler
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            // cancel
            break;
        case 1:
            // ok
            [self deleteMeeting];
            [self.navigationController popToViewController:((AppDelegate *)[[UIApplication sharedApplication] delegate]).home animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)deleteMeeting{
    if (_meetingObject == nil) {
        return;
    }
    
    DataManager *dm = [[DataManager alloc] init];
    [dm deleteMeetingSoft:_meetingObject];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"meeting_guests_segue"]) {
        
        GuestListController *vc = [segue destinationViewController];
        [vc setMeetingObject:_meetingObject];
        
    }
    
}


@end

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

@interface MeetingViewController (){
    BOOL home;
}

@end



@implementation MeetingViewController

@synthesize meeters = _meeters;
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
    
    // Do any additional setup after loading the view.
    if (home) {
        [self.nameLabel setText:[self.meetingObject valueForKey:@"meeting_name"]];
        [self.nameLabel setHidden:NO];
        [self.numMeetersLabel setText:[NSString stringWithFormat:@"%lu invitees", (unsigned long)[self.meetingObject mutableSetValueForKey:@"invites"].count]];
        [self.nameTextField setHidden:YES];
        [self.sendContactsButton setTitle:@"Edit Contacts" forState:UIControlStateNormal];
        [self.detailsTextView setText:[_meetingObject valueForKey:@"meeting_description"]];
    }else{
        [self.nameLabel setHidden:YES];
        [self.nameTextField setHidden:NO];
        [self.nameTextField setDelegate:self];
        [self.numMeetersLabel setText:[NSString stringWithFormat:@"%lu invitees", (unsigned long)_meeters.count]];
        [self.sendContactsButton setTitle:@"Send Invites" forState:UIControlStateNormal];
    }
    
    [self.comeToMeSwitch setOn:((NSNumber *)[_meetingObject valueForKey:@"is_ComeToMe"]).boolValue];
    self.detailsTextView.delegate = self;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // hides keyboard on return
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [_meetingObject setValue:textView.text forKey:@"meeting_description"];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
        return NO;
    }
    
    return YES;
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

- (IBAction)sendContactsBtnHit:(id)sender {
    
    if (!home) {
        // check for name
        if ([self.nameLabel.text isEqualToString:@""]) {
            NSLog(@"No meeting name! Ragequit.");
            return;
        }
        
        // __Core Data stuff ahead__
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // create meeting
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *meeting_object = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Meeting"
                                           inManagedObjectContext:context];
        [meeting_object setValue:self.nameTextField.text forKey:@"meeting_name"];
        if (![self.detailsTextView.text isEqualToString:@""] && ![self.detailsTextView.text isEqualToString:@"optional"]) {
            [meeting_object setValue:self.detailsTextView.text forKeyPath:@"meeting_description"];
        }
        [meeting_object setValue:[NSNumber numberWithBool:self.comeToMeSwitch.isOn] forKeyPath:@"is_ComeToMe"];
        [meeting_object setValue:[NSNumber numberWithInt:[appDelegate getId]] forKeyPath:@"id"];
        [meeting_object setValue:[NSDate date] forKeyPath:@"created_date"];
        
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
        [meeting_object setValue:friendsSet forKeyPath:@"invites"];
        
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
        
        
        // save it!
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        // TODO: send meeting & invites
        
        
        // unwind segue to home
        [self.navigationController popToViewController:appDelegate.home animated:YES];
        
    }else{
        // TODO: go to contacts
    }
    
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
}


- (IBAction)comeToMeSwitched:(id)sender {
    [_meetingObject setValue:[NSNumber numberWithBool:[self.comeToMeSwitch isOn]] forKey:@"is_ComeToMe"];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
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
    NSMutableSet *ppl = [_meetingObject mutableSetValueForKey:@"invites"];
    for (NSManagedObject *p in ppl) {
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext deleteObject:p];
    }
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext deleteObject:_meetingObject];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
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

@end

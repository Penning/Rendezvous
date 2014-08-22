//
//  ContactsViewController.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "ContactsViewController.h"
#import "MeetingReasonViewController.h"
#import "CurrentUser.h"
#import "ContactsCell.h"
#import "Meeting.h"
#import "DataManager.h"
#import "Friend.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController{
    AppDelegate *appDelegate;
    BOOL useShortcut;
    NSString *meetingName;
    BOOL hasAppInstalled;
    NSMutableArray *all_contacts;
}

@synthesize meeters;
@synthesize meetingObject = _meetingObject;
@synthesize activityIndicator = _activityIndicator;
@synthesize contactsFilterBar = _contactsFilterBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (meeters == nil) {
        meeters = [[NSMutableArray alloc] init];
    }

    meetingName = [NSString stringWithFormat:@"Rendezvous%u", arc4random()%10000];
    [self.meetingNameBarBtn setTitle:meetingName];

    if(![_activityIndicator isAnimating]) {
        [self.tableView reloadData];
    }
    
    [self.tableView setAllowsMultipleSelection:YES];
    [_contactsFilterBar setSelectedItem:_contactsItem];
    [_contactsFilterBar setDelegate:self];
    hasAppInstalled = TRUE;
}

- (void)viewWillAppear:(BOOL)animated{
    appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setContacts:self];

    if ([meeters count] > 0) {
//        NSString *tempMeetingName = @"w/: ";
//        for (Friend *f in meeters) {
//            if (tempMeetingName.length > 20) {
//                tempMeetingName = [tempMeetingName stringByAppendingString:@"& more"];
//                break;
//            }else{
//                tempMeetingName = [tempMeetingName stringByAppendingString:[NSString stringWithFormat:@"%@, ", f.first_name]];
//            }
//        }
//        if ([tempMeetingName characterAtIndex:tempMeetingName.length-2] == ',') {
//            tempMeetingName = [tempMeetingName stringByReplacingCharactersInRange:NSMakeRange(tempMeetingName.length-2, 2) withString:@""];
//        }
//        meetingName = tempMeetingName;
//        [self.meetingNameBarBtn setTitle:meetingName];
        [self.navigationController setToolbarHidden:NO animated:animated];
    }else{
        [self.navigationController setToolbarHidden:YES animated:animated];
    }

    [self.tableView reloadData];

    if(appDelegate.user.friends.count == 0) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.color = [UIColor purpleColor];
        _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
        [self.view addSubview: _activityIndicator];

        [_activityIndicator startAnimating];
        
        [self.tableView reloadData];
    }
    
//    if(appDelegate.user.friendsWithoutApp.count == 0) {
//        [self getContacts];
//    }

    [self.tableView reloadData];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


-(void) delayedReloadData {
    [self.tableView reloadData];
}


- (void) viewWillDisappear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(hasAppInstalled == TRUE) {
        NSLog(@"friendsWithApp: %lu", (unsigned long)appDelegate.user.friendsWithApp.count);
        return [appDelegate.user.friendsWithApp count];
    } else {
        NSLog(@"friendsWithoutApp: %lu", (unsigned long)appDelegate.user.friendsWithoutApp.count);
        return [appDelegate.user.friendsWithoutApp count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(hasAppInstalled == TRUE) {
        NSLog(@"Add to Meeting");
        return @"Add to Meeting";
    } else {
        NSLog(@"Invite to use Rendezvous");
        return @"Invite to use Rendezvous";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];

    if (cell == nil) {
        cell = [[ContactsCell alloc] init];
    }

    // Configure the cell...
    if(hasAppInstalled == TRUE) {
        [cell initCellDisplay:[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row]];
        cell.appInstalled = [NSNumber numberWithInt:1];
    } else {
        [cell initCellDisplay:[appDelegate.user.friendsWithoutApp objectAtIndex:indexPath.row]];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];

    if(hasAppInstalled == TRUE) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID = %@", [[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row] facebookID]];
//        NSArray *filteredArray = [meeters filteredArrayUsingPredicate:predicate];
        //NSLog(@"FilteredArray: %@", filteredArray);
        
        if (![cell isHighlighted]) {
            // add to meeting
            [meeters addObject:((Friend *)[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row])];
        }

        if ([meeters count] > 0) {
            // show toolbar
            [self.navigationController setToolbarHidden:NO animated:YES];
        }else{
            // hide toolbar
            [self.navigationController setToolbarHidden:YES animated:YES];
        }

        
    } else {
        [cell setUserInteractionEnabled:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // remove from meeting
    for (Friend *f in meeters) {
        if ([f.facebookID isEqualToString:((Friend*)[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row]).facebookID]) {
            [meeters removeObject:f];
            NSLog(@"removed %@", f.facebookID);
            break;
        }
    }

}

- (IBAction)okBtnHit:(id)sender {
    useShortcut = YES;
    
    Meeting *newMeeting = [[Meeting alloc] init];
    newMeeting.name = meetingName;
    newMeeting.description = @"";
    [newMeeting setComeToMe:NO];
    
    DataManager *dm = [[DataManager alloc] init];
    [dm createMeeting:newMeeting withInvites:meeters withReasons:@[]];
    
    
    // unwind segue to home
    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [self.navigationController popToViewController:appDelegate.home animated:YES];
}

- (IBAction)editBtnHit:(id)sender {
    useShortcut = NO;
    [self performSegueWithIdentifier:@"reason_segue" sender:self];
}

- (IBAction)saveEditsBtnHit:(id)sender {
    
    // clear invites
    NSMutableSet *oldInvitesSet = [_meetingObject mutableSetValueForKey:@"invites"];
    for (NSManagedObject *person in oldInvitesSet) {
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext deleteObject:person];
    }
    [_meetingObject setValue:nil forKey:@"invites"];
    
    // create friends
    NSMutableSet *friendsSet = [[NSMutableSet alloc] init];
    for (Friend *f in self.meeters) {
        NSManagedObject *newInvitee = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Person"
                                       inManagedObjectContext:((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext];
        [newInvitee setValue:f.name forKeyPath:@"name"];
        [newInvitee setValue:f.first_name forKeyPath:@"first_name"];
        [newInvitee setValue:f.last_name forKeyPath:@"last_name"];
        [newInvitee setValue:f.facebookID forKeyPath:@"facebook_id"];
        [friendsSet addObject:newInvitee];
    }
    
    // add invitees to meeting
    [_meetingObject setValue:friendsSet forKey:@"invites"];
    
    // save
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
    
    // go back
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"reason_segue"]) {
        MeetingReasonViewController *vc = (MeetingReasonViewController *)[segue destinationViewController];
        [vc setMeeters:meeters];
        [vc setFriends:appDelegate.user.friends];
        [vc setMeetingName:meetingName];
        if (useShortcut) {
            [vc initForSend];
        }
    }
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Tab Bar Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *) item {
    if([item isEqual:_contactsItem]) {
        NSLog(@"CONTACTS SELECTED");
        hasAppInstalled = TRUE;
    } else {
        NSLog(@"ADDRESS BOOK SELECTED");
        hasAppInstalled = FALSE;
        [self getContacts];
    }
    [self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.25f];
}

- (void) reloadTable {
    [self.tableView reloadData];
}

#pragma mark - Email
- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = @"Invite to use ";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@appcoda.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ABPeoplePickerNavigationController Delegate method implementation

- (void) getContacts {
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
//    
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
//        NSArray *folks = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
//        NSLog(@"%@",folks);
//    });
    
    ABAddressBookRef addressBook = ABAddressBookCreate(); // create address book reference object
    NSArray *abContactArray = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook); // get address book contact array
    
    NSInteger totalContacts = [abContactArray count];
    
    for(NSUInteger loop= 0 ; loop < totalContacts; loop++) {
        ABRecordRef record = (__bridge ABRecordRef)[abContactArray objectAtIndex:loop]; // get address book record
        
        if(ABRecordGetRecordType(record) ==  kABPersonType) {
//            ABRecordID recordId = ABRecordGetRecordID(record); // get record id from address book record
            Friend *f;
            
//            f. = [NSString stringWithFormat:@"%d",recordId]; // get record id string from record id
            
            NSString *firstNameString = (__bridge NSString*)ABRecordCopyValue(record,kABPersonFirstNameProperty); // fetch contact first name from address book
            NSString *lastNameString = (__bridge NSString*)ABRecordCopyValue(record,kABPersonLastNameProperty); // fetch contact last name from address book
            f.name = [NSString stringWithFormat:@"%@ %@", firstNameString, lastNameString];
            
//            NSString *phnumber = (__bridge NSString *)ABRecordCopyValue(record, kABPersonPhoneProperty);
            f.email = (__bridge NSString *)ABRecordCopyValue(record, kABPersonEmailProperty);
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", f.name];
            NSArray *filteredArray = [appDelegate.user.friendsWithApp filteredArrayUsingPredicate:predicate];
            
            if([filteredArray count] == 0) {
                [appDelegate.user.friendsWithoutApp addObject:f];
            }
            NSLog(@"%@", f.name);
        }
        [self.tableView reloadData];
    }
//    CFErrorRef * error = NULL;
//    addressBook = ABAddressBookCreateWithOptions(NULL, error);
//    if(all_contacts == nil) {
//        all_contacts = [[NSMutableArray alloc] init];
//    }
//    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
//        if (granted) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
//                CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
//                
//                for(int i = 0; i < numberOfPeople; i++){
//                    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
//                    
//                    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//                    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
//                    NSLog(@"Name:%@ %@", firstName, lastName);
//                    
//                    NSString *email = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonEmailProperty));
//                    
//                    Friend *friend = [[Friend alloc] init];
//                    friend.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
//                    friend.email = email;
//                    
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", friend.name];
//                    NSArray *filteredArray = [appDelegate.user.friendsWithApp filteredArrayUsingPredicate:predicate];
//                    
//                    if([filteredArray count] == 0) {
//                        [appDelegate.user.friendsWithoutApp addObject:friend];
//                    }
//                }
//                [self.tableView reloadData];
//                NSLog(@"Friends w/o app: \n%@", appDelegate.user.friendsWithoutApp);
//            });
//        }
//    });
}

@end

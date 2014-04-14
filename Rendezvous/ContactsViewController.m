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

@interface ContactsViewController ()

@end

@implementation ContactsViewController{
    AppDelegate *appDelegate;
    BOOL useShortcut;
    NSString *meetingName;
}

@synthesize meeters;
@synthesize meetingObject = _meetingObject;
@synthesize activityIndicator = _activityIndicator;

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        NSLog(@"friendsWithApp: %lu", (unsigned long)appDelegate.user.friendsWithApp.count);
        return [appDelegate.user.friendsWithApp count];
    } else {
        NSLog(@"friendsWithoutApp: %lu", (unsigned long)appDelegate.user.friendsWithoutApp.count);
        return [appDelegate.user.friendsWithoutApp count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if(section == 0) {
        return @"Add to Meeting";
    } else {
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
    if(indexPath.section == 0) {
        [cell initCellDisplay:[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row]];
        cell.appInstalled = [NSNumber numberWithInt:1];
        [cell.addUserBtn setHidden:YES];
    } else {
        [cell initCellDisplay:[appDelegate.user.friendsWithoutApp objectAtIndex:indexPath.row]];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];

    if(indexPath.section == 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookID = %@", [[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row] facebookID]];
        NSArray *filteredArray = [meeters filteredArrayUsingPredicate:predicate];
        //NSLog(@"FilteredArray: %@", filteredArray);
        
        if ([cell accessoryType] == UITableViewCellAccessoryNone && [filteredArray count] == 0) {
            // add to meeting
            NSLog(@"checking from didselect");

            [meeters addObject:((Friend *)[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row])];

        }else{
            // remove from meeting
            NSLog(@"unchecking from didselect");
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            for (Friend *f in meeters) {
                if ([f.facebookID isEqualToString:((Friend*)[appDelegate.user.friendsWithApp objectAtIndex:indexPath.row]).facebookID]) {
                    [meeters removeObject:f];
                    break;
                }
            }
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

 
@end

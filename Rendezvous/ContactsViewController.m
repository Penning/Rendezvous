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

@interface ContactsViewController ()

@end

@implementation ContactsViewController{
    BOOL useShortcut;
    NSString *meetingName;
}

@synthesize friends;
@synthesize friendsWithApp;
@synthesize friendsWithoutApp;
@synthesize meeters;
@synthesize meetingObject = _meetingObject;

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
    
    meetingName = @"";
    [self.meetingNameBarBtn setTitle:meetingName];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([meeters count] > 0) {
        NSString *tempMeetingName = @"w/: ";
        for (Friend *f in meeters) {
            if (tempMeetingName.length > 20) {
                tempMeetingName = [tempMeetingName stringByAppendingString:@"& more"];
                break;
            }else{
                tempMeetingName = [tempMeetingName stringByAppendingString:[NSString stringWithFormat:@"%@, ", f.first_name]];
            }
        }
        if ([tempMeetingName characterAtIndex:tempMeetingName.length-2] == ',') {
            tempMeetingName = [tempMeetingName stringByReplacingCharactersInRange:NSMakeRange(tempMeetingName.length-2, 2) withString:@""];
        }
        meetingName = tempMeetingName;
        [self.meetingNameBarBtn setTitle:meetingName];
        [self.navigationController setToolbarHidden:NO animated:animated];
    }else{
        [self.navigationController setToolbarHidden:YES animated:animated];
    }

    friendsWithApp = [[NSMutableArray alloc] init];
    friendsWithoutApp = [[NSMutableArray alloc] init];

    //Query all Parse users
    PFQuery *query = [PFUser query];
    NSArray *users = [query findObjects];
    [query cancel];

    for(Friend *friend in friends) {
        NSArray *matches = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains %@", friend.name]];
        if(matches.count > 0) {
            [friendsWithApp addObject:friend];
        }
        else {
            [friendsWithoutApp addObject:friend];
        }
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
        NSLog(@"friendsWithApp: %lu", (unsigned long)friendsWithApp.count);
        return [friendsWithApp count];
    } else {
        NSLog(@"friendsWithoutApp: %lu", (unsigned long)friendsWithoutApp.count);
        return [friendsWithoutApp count];
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
        [cell initCellDisplay:[friendsWithApp objectAtIndex:indexPath.row]];
        cell.appInstalled = [NSNumber numberWithInt:1];
        [cell.addUserBtn setHidden:YES];

        // show checkmark if meeter
        BOOL isMeeter = NO;
        for (Friend *f in meeters) {
            if ([f.facebookID isEqualToString: ((Friend *)[friendsWithApp objectAtIndex:indexPath.row]).facebookID]) {
                isMeeter = YES;
                break;
            }
        }
        if (isMeeter) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else {
        [cell initCellDisplay:[friendsWithoutApp objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];

    if(indexPath.section == 0) {
        if ([cell accessoryType] == UITableViewCellAccessoryNone ||
            [meeters containsObject:[friendsWithApp objectAtIndex:indexPath.row]]) {
            // add to meeting

            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [meeters addObject:[friendsWithApp objectAtIndex:indexPath.row]];

        }else{
            // remove from meeting

            [cell setAccessoryType:UITableViewCellAccessoryNone];
            for (Friend *f in meeters) {
                if (f.facebookID == ((Friend*)[friendsWithApp objectAtIndex:indexPath.row]).facebookID) {
                    [meeters removeObject:f];
                    break;
                }
            }
        }

        if ([meeters count] > 0) {
            // show toolbar
            [self.navigationController setToolbarHidden:NO animated:YES];

            NSString *tempMeetingName = @"w/: ";
            for (Friend *f in meeters) {
                if (tempMeetingName.length > 20) {
                    tempMeetingName = [tempMeetingName stringByAppendingString:@"& more"];
                    break;
                }else{
                    tempMeetingName = [tempMeetingName stringByAppendingString:[NSString stringWithFormat:@"%@, ", f.first_name]];
                }
            }
            if ([tempMeetingName characterAtIndex:tempMeetingName.length-2] == ',') {
                tempMeetingName = [tempMeetingName stringByReplacingCharactersInRange:NSMakeRange(tempMeetingName.length-2, 2) withString:@""];
            }
            meetingName = tempMeetingName;

            [self.meetingNameBarBtn setTitle:meetingName];
        }else{
            // hide toolbar
            [self.navigationController setToolbarHidden:YES animated:YES];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [cell setUserInteractionEnabled:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

- (IBAction)okBtnHit:(id)sender {
    useShortcut = YES;
    [self performSegueWithIdentifier:@"reason_segue" sender:self];
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
        [vc setFriends:friends];
        [vc setMeetingName:meetingName];
        if (useShortcut) {
            [vc initForSend];
        }
    }
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

 
@end

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
    NSString *meetingName;
}

@synthesize friends;
@synthesize friendsWithApp;
@synthesize friendsWithoutApp;
@synthesize meeters;

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
    
    meetingName = [NSString stringWithFormat:@"meeting%u", arc4random() % 9999];
    [self.meetingNameBarBtn setTitle:meetingName];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([meeters count] > 0) {
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
            if (f.facebookID == ((Friend *)[friends objectAtIndex:indexPath.row]).facebookID) {
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
        cell.appInstalled = [NSNumber numberWithInt:0];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];

    if(indexPath.section == 0) {
        if ([cell accessoryType] == UITableViewCellAccessoryNone) {
            // add to meeting

            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [meeters addObject:[friends objectAtIndex:indexPath.row]];
        }else{
            // remove from meeting

            [cell setAccessoryType:UITableViewCellAccessoryNone];
            for (Friend *f in meeters) {
                if (f.facebookID == ((Friend*)[friends objectAtIndex:indexPath.row]).facebookID) {
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
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"reason_segue"]) {
        MeetingReasonViewController *vc = (MeetingReasonViewController *)[segue destinationViewController];
        [vc setMeeters:meeters];
        [vc setFriends:friends];
    }
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

 
@end

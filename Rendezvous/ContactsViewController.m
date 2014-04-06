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
    
    meetingName = @"";
    [self.meetingNameBarBtn setTitle:meetingName];
}

- (void)viewWillAppear:(BOOL)animated{
    if ([meeters count] > 0) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }else{
        [self.navigationController setToolbarHidden:YES animated:animated];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];

    if (cell == nil) {
        cell = [[ContactsCell alloc] init];
    }

    // Configure the cell...
    [cell initCellDisplay:[friends objectAtIndex:indexPath.row]];
    
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
    
    NSString *tempMeetingName = @"w/: ";
    for (Friend *f in meeters) {
        if (tempMeetingName.length > 25) {
            tempMeetingName = [tempMeetingName stringByAppendingString:@"& more"];
            break;
        }else{
            tempMeetingName = [tempMeetingName stringByAppendingString:[NSString stringWithFormat:@"%@ ", f.first_name]];
        }
    }
    meetingName = tempMeetingName;
    
    [self.meetingNameBarBtn setTitle:meetingName];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (IBAction)okBtnHit:(id)sender {
    useShortcut = YES;
    [self performSegueWithIdentifier:@"reason_segue" sender:self];
}

- (IBAction)editBtnHit:(id)sender {
    useShortcut = NO;
    [self performSegueWithIdentifier:@"reason_segue" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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

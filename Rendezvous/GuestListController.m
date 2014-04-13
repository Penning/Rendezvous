//
//  GuestListController.m
//  Rendezvous
//
//  Created by Adam Oxner on 4/12/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "GuestListController.h"
#import "GuestListCell.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface GuestListController ()

@end

@implementation GuestListController{
    AppDelegate *appDelegate;
    NSArray *guestArray;
}

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
    
    appDelegate = [[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.meetingCreatedLabel setText:[NSString stringWithFormat:@"Created: %@",[dateFormatter stringFromDate:[_meetingObject valueForKey:@"created_date"]]]] ;
    
    // query people
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Person"
                inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"meeting.parse_object_id == %@ OR administors.parse_object_id == %@",
                              [_meetingObject valueForKey:@"parse_object_id"],
                              [_meetingObject valueForKey:@"parse_object_id"]];
    [request setPredicate:predicate];
    
    NSError *error;
    guestArray = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (guestArray) {
        return guestArray.count;
    }
    
    return 0;
}


#pragma mark - Cell Configuration

- (void)configureCell:(GuestListCell *)cell forIndexPath:(NSIndexPath *)indexPath{
    // configure
    
    if ([[[guestArray objectAtIndex:indexPath.row] valueForKey:@"facebook_id"] isEqualToString:appDelegate.user.facebookID]) {
        [cell.imageView setImageWithURL:appDelegate.user.pictureURL placeholderImage:[UIImage imageNamed:@"111-user"]];
    }else{
        for (Friend *fr in appDelegate.user.friends) {
            
            if ([fr.facebookID isEqualToString:[[guestArray objectAtIndex:indexPath.row] valueForKey:@"facebook_id"]]) {
                [cell.imageView setImageWithURL:fr.pictureURL placeholderImage:[UIImage imageNamed:@"111-user"]];
            }
            
        }
    }
    
    
    
    if (!cell.imageView) {
        [cell.imageView setImage:[UIImage imageNamed:@"111-user"]];
    }
    
    [cell.nameLabel setText:[NSString stringWithFormat:@"%@", [[guestArray objectAtIndex:indexPath.row] valueForKey:@"name"]]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Person"
                inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebook_id == %@ AND (accepted_meeting.parse_object_id == %@ OR administors.parse_object_id == %@ OR declined_meeting.parse_object_id == %@)",
                              [[guestArray objectAtIndex:indexPath.row] valueForKey:@"facebook_id"],
                              [_meetingObject valueForKey:@"parse_object_id"],
                              [_meetingObject valueForKey:@"parse_object_id"],
                              [_meetingObject valueForKey:@"parse_object_id"]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *temp = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if (temp && temp.count > 0 && ![[temp objectAtIndex:0] valueForKey:@"declined_meeting"]) {
        // accepted
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else if (temp && temp.count > 0 &&
              [[[temp objectAtIndex:0] valueForKeyPath:@"declined_meeting.parse_object_id"]
               isEqualToString:[_meetingObject valueForKey:@"parse_object_id"]]){
        // declined
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_x"]]];
    }else{
        // no response
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuestListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"guest_cell"];
    
    if (!cell) {
        cell = [[GuestListCell alloc] init];
    }
    
    // Configure the cell...
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Cell selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
}

@end

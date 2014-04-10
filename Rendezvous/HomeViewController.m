//
//  HomeViewController.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "HomeViewController.h"
#import "MeetingViewController.h"
#import "ContactsViewController.h"
#import <Parse/Parse.h>
#import "CurrentUser.h"
#import "LocationViewController.h"
#import "LocationSuggestionsLookup.h"
#import "AcceptDeclineController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    CurrentUser *current_user;
    AppDelegate *appDelegate;
    NSIndexPath *lastSelected;
}

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

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
    
    //fetched results controller
    appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *fetchEntity = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:context];
    // Configure the request's entity, and optionally its predicate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setEntity:fetchEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_old == %@", @NO];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                  initWithFetchRequest:fetchRequest
                  managedObjectContext:context
                  sectionNameKeyPath:nil
                  cacheName:nil];
    [_fetchedResultsController setDelegate:self];
    
    
    NSError *error;
    BOOL success = [_fetchedResultsController performFetch:&error];
    if (!success) {
        NSLog(@"Core data error. Could not fetch results controller.");
    }

    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.tableView reloadData];
    
    [appDelegate setHome:self];
}


- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    //DataManager *dm = [[DataManager alloc] init];
    //[dm fetchMeetingUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cellSingleTapped:(HomeCell *)sender{
    // a cell was single tapped
    
    if (![appDelegate.user.facebookID isEqualToString:sender.adminFbId]){
        // admin
        lastSelected = sender.indexPath;
        [self performSegueWithIdentifier:@"home_accept_decline_segue" sender:self];
    }else{
        // not admin
        lastSelected = sender.indexPath;
        [self performSegueWithIdentifier:@"home_details_segue" sender:self];
    }
    
    
}

- (void)cellDoubleTapped:(HomeCell *)sender{
    // a cell was double tapped
    
    // must be admin
    if (![appDelegate.user.facebookID isEqualToString:sender.adminFbId]) return;
    
    lastSelected = sender.indexPath;
    [self performSegueWithIdentifier:@"close_meeting_segue" sender:self];
}

- (IBAction)logoutBtnHit:(id)sender {
    // logout btn hit
    
    
}

- (void)reloadMeetings{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Meeting"
                                   inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"created_date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil){
        return _managedObjectContext;
    }
    
    if (appDelegate == nil) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    _managedObjectContext = appDelegate.managedObjectContext;
    return _managedObjectContext;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Cell handling

- (void)configureCell:(UITableViewCell *)cell1 atIndexPath:(NSIndexPath *)indexPath{
    NSManagedObject *meeting_object = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    HomeCell *cell = (HomeCell *)cell1;
    
    [cell setIndexPath:indexPath];
    [cell initializeGestureRecognizer];
    [cell setParentController:self];
    [cell setAdminFbId:[meeting_object valueForKeyPath:@"admin.facebook_id"]];
    
    
    
    [cell.acceptedLabel setText:[NSString
                                 stringWithFormat:@"%@/%lu",
                                 [meeting_object valueForKey:@"num_responded"],
                                 [meeting_object mutableSetValueForKey:@"invites"].count]];
    

    
    if (![cell.adminFbId isEqualToString:appDelegate.user.facebookID]) {
        // not admin
        [cell.doubleTapLabel setText:@"Tap to RSVP"];
        [cell.meetingAdmin setText:[meeting_object valueForKey:@"meeting_name"]];
        [cell.meetingName setText:[NSString stringWithFormat:@"From: %@",[meeting_object valueForKeyPath:@"admin.name"]]];
    }else{
        // admin
        [cell.doubleTapLabel setText:@"Double tap to close invites"];
        [cell.meetingName setText:[meeting_object valueForKey:@"meeting_name"]];
        [cell.meetingAdmin setText:@""];
    }
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home_cell"];
     if (cell == nil) {
         cell = [[HomeCell alloc] init];
     }
     
     // Configure the cell...
     [self configureCell:cell atIndexPath:indexPath];
 
     return cell;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Navigation

- (IBAction)settingsBtnHit:(id)sender {
    [self performSegueWithIdentifier:@"home_settings_segue" sender:self];
}
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([[segue identifier] isEqualToString:@"home_details_segue"]) {
         
         MeetingViewController *vc = (MeetingViewController *)[segue destinationViewController];
         [vc setMeetingObject:[_fetchedResultsController objectAtIndexPath:lastSelected]];
         [vc initFromHome];
         
     } else if([[segue identifier] isEqualToString:@"new_meeting_segue"]) {
         
         appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         current_user = appDelegate.user;

         if(current_user.friends.count == 0) {
             [current_user getMyInformation];
         }

         ContactsViewController *vc = (ContactsViewController *)[segue destinationViewController];
         NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                      ascending:YES];
         NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
         vc.friends = [current_user.friends sortedArrayUsingDescriptors:sortDescriptors];
     } else if([[segue identifier] isEqualToString:@"close_meeting_segue"]) {
         
         LocationViewController *vc = (LocationViewController *)[segue destinationViewController];
         LocationSuggestionsLookup *locationSuggestionsLookup = [[LocationSuggestionsLookup alloc] init];
         locationSuggestionsLookup.locationViewController = vc;
         [locationSuggestionsLookup getSuggestionsWithCoreData:[_fetchedResultsController objectAtIndexPath:lastSelected]];


     } else if ([[segue identifier] isEqualToString:@"home_accept_decline_segue"]){
         
         AcceptDeclineController *vc = (AcceptDeclineController *)[segue destinationViewController];
         [vc setLocalMeeting:[_fetchedResultsController objectAtIndexPath:lastSelected]];
         
         
     } else if ([[segue identifier] isEqualToString:@"home_settings_segue"]){
         
         // to settings
         
     }
 }

#pragma mark - FetchedResultsController delegates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}



@end

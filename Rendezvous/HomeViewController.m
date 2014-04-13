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
#import "DataManager.h"
#import "FinalViewController.h"

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
    [self performSelectorInBackground:@selector(waitAndUpdate) withObject:nil];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)waitAndUpdate{
    while (!appDelegate.user.facebookID) {
        // do nothing
        sleep(0.5);
    }
    [appDelegate getMeetingUpdates];
}

- (void)viewDidAppear:(BOOL)animated{
    //DataManager *dm = [[DataManager alloc] init];
    //[dm fetchMeetingUpdates];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cellSingleTapped:(HomeCell *)sender{
    // a cell was single tapped
    
    lastSelected = sender.indexPath;
    [self performSegueWithIdentifier:@"home_details_segue" sender:self];
}

- (void)cellDoubleTapped:(HomeCell *)sender{
    // a cell was double tapped
    
    lastSelected = sender.indexPath;
    NSManagedObject *relevantMeeting = [_fetchedResultsController objectAtIndexPath:lastSelected];
    
    if ([appDelegate.user.facebookID isEqualToString:sender.adminFbId]) {
        // admin
        
        if ([[relevantMeeting valueForKey:@"status"] isEqualToString:@"open"]) {
            // close
            [self performSegueWithIdentifier:@"close_meeting_segue" sender:self];
            
        }else if ([[relevantMeeting valueForKey:@"status"] isEqualToString:@"closed"]) {
            // choose location
            [self performSegueWithIdentifier:@"close_meeting_segue" sender:self];
            
        }else if ([[relevantMeeting valueForKey:@"status"] isEqualToString:@"final"]) {
            // view location
            [self performSegueWithIdentifier:@"home_final_segue" sender:self];
        }
        
    }else{
        // not admin
        
        if ([[relevantMeeting valueForKey:@"status"] isEqualToString:@"open"]) {
            // RSVP
//            [self performSegueWithIdentifier:@"home_accept_decline_segue" sender:self];
            [[[UIAlertView alloc] initWithTitle:@"RSVP"
                                        message:[NSString stringWithFormat:@"Rendezvous with %@", [relevantMeeting valueForKeyPath:@"admin.name"]]
                                       delegate:self
                              cancelButtonTitle:@"Later"
                              otherButtonTitles:@"Accept", @"Accept w/o Location", @"Decline", nil] show];
        }else if ([[relevantMeeting valueForKey:@"status"] isEqualToString:@"closed"]) {
            // do nothing
            
        }else if ([[relevantMeeting valueForKey:@"status"] isEqualToString:@"final"]) {
            // view location
            [self performSegueWithIdentifier:@"home_final_segue" sender:self];
        }
    }
    
    
    
    
}

- (IBAction)refreshBtnHit:(id)sender {
    if (appDelegate.user.facebookID) {
        [appDelegate getMeetingUpdates];
    }
}

- (void)reloadMeetings{
    [self.tableView reloadData];
}

#pragma mark - UIAlertView handling

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // later; ignore
    }else {
        // act

        NSManagedObject *relevantMeeting = [_fetchedResultsController objectAtIndexPath:lastSelected];
        PFObject *parseMeeting = [PFObject objectWithoutDataWithClassName:@"Meeting"
                                                                 objectId:[relevantMeeting valueForKey:@"parse_object_id"]];

//        NSLog(@"Button title: %@", [alertView buttonTitleAtIndex:buttonIndex]);

        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept w/ Current Location"]) {
            // accept

            // -------Parse location--------
            //
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {

                if (!error) {
                    [parseMeeting addUniqueObject:geoPoint forKey:@"meeter_locations"];
                    [parseMeeting addUniqueObject:appDelegate.user.facebookID forKey:@"fb_ids_accepted_users"];
                    [parseMeeting incrementKey:@"num_responded"];
                    [parseMeeting saveInBackground];
                }else{
                    NSLog(@"Location error: %@", error);
                }

            }];

            [relevantMeeting setValue:@YES forKey:@"user_responded"];
            [appDelegate saveContext];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept w/o Location"]) {
            // accept
            [parseMeeting addUniqueObject:appDelegate.user.facebookID forKey:@"fb_ids_accepted_users"];
            [parseMeeting incrementKey:@"num_responded"];
            [parseMeeting saveInBackground];

            [relevantMeeting setValue:@YES forKey:@"user_responded"];
            [appDelegate saveContext];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Decline"]) {
            // decline
//            NSLog(@"Alert: %@", [alertView buttonTitleAtIndex:buttonIndex]);
            [parseMeeting addUniqueObject:appDelegate.user.facebookID forKey:@"fb_ids_declined_users"];
            [parseMeeting incrementKey:@"num_responded"];
            [parseMeeting saveInBackground];

            [relevantMeeting setValue:@YES forKey:@"user_responded"];
            [appDelegate saveContext];
        }
        [appDelegate getMeetingUpdates];
        
    }
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
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate *createdDate = [meeting_object valueForKey:@"created_date"];
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit|
                                                                             NSDayCalendarUnit|
                                                                             NSMinuteCalendarUnit|
                                                                             NSSecondCalendarUnit)
                                                                   fromDate:createdDate
                                                                     toDate:[NSDate date]
                                                                    options:0];
    NSString *dateString = @"problem getting date";
    if (components.day < 1 && components.hour > 0) {
        dateString = [NSString stringWithFormat:@"%ld hours ago", (long)components.hour];
    }else if (components.hour < 1 && components.minute > 0){
        dateString = [NSString stringWithFormat:@"%ld minutes ago", (long)components.minute];
    }if (components.minute < 1){
        dateString = [NSString stringWithFormat:@"%ld seconds ago", (long)components.second];
    }
    
    [cell.dateLabel setText:dateString];
    [cell.titleLabel setText:[meeting_object valueForKey:@"meeting_name"]];

    [cell.adminImageView setImage:[UIImage imageNamed:@"admin_indicator"]];

    if ([cell.adminFbId isEqualToString:appDelegate.user.facebookID]) {
        // admin
        
        if ([[meeting_object valueForKey:@"status"]  isEqual: @"open"]) {
            [cell.statusImageView setImage:[UIImage imageNamed:@"meeting_open"]];
            [cell.rightLabel setText:@"Double tap to close."];
        }else if ([[meeting_object valueForKey:@"status"]  isEqual: @"closed"]){
            [cell.statusImageView setImage:[UIImage imageNamed:@"meeting_closed"]];
            [cell.rightLabel setText:@"Double tap to choose location."];
        }else if ([[meeting_object valueForKey:@"status"]  isEqual: @"final"]){
            [cell.statusImageView setImage:[UIImage imageNamed:@"finalized_meeting"]];
            [cell.rightLabel setText:@"Double tap to view location."];
        }

        [cell.adminImageView setHidden:NO];
    }else{
        // not admin
        
        if ([[meeting_object valueForKey:@"status"]  isEqual: @"open"]) {
            [cell.statusImageView setImage:[UIImage imageNamed:@"meeting_open"]];
            [cell.rightLabel setText:@"Double tap to RSVP"];
        }else if ([[meeting_object valueForKey:@"status"]  isEqual: @"closed"]){
            [cell.statusImageView setImage:[UIImage imageNamed:@"meeting_closed"]];
            [cell.rightLabel setText:@""];
        }else if ([[meeting_object valueForKey:@"status"]  isEqual: @"final"]){
            [cell.statusImageView setImage:[UIImage imageNamed:@"finalized_meeting"]];
            [cell.rightLabel setText:@"Double tap to view location."];
        }
        [cell.adminImageView setHidden:YES];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// when deleting...
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DataManager *dm = [[DataManager alloc] init];
        if ([[[_fetchedResultsController objectAtIndexPath:indexPath] valueForKeyPath:@"admin.facebook_id"] isEqualToString:appDelegate.user.facebookID]) {
            // if admin, delete on parse and mark local as old
            
            [dm deleteMeetingSoft:[_fetchedResultsController objectAtIndexPath:indexPath]];
        }else{
            // just mark local as old
            
            [dm putInHistory:[_fetchedResultsController objectAtIndexPath:indexPath]];
        }
        
    }
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

//         if(appDelegate.user.friends.count == 0) {
//             [current_user getMyInformation];
//         }

         ContactsViewController *vc = (ContactsViewController *)[segue destinationViewController];
     } else if([[segue identifier] isEqualToString:@"close_meeting_segue"]) {

         LocationViewController *vc = (LocationViewController *)[segue destinationViewController];
         LocationSuggestionsLookup *locationSuggestionsLookup = [[LocationSuggestionsLookup alloc] init];
         locationSuggestionsLookup.locationViewController = vc;
         vc.meeting = [vc.meeting toCoreData:[_fetchedResultsController objectAtIndexPath:lastSelected]];
         [locationSuggestionsLookup getSuggestionsWithCoreData:[_fetchedResultsController objectAtIndexPath:lastSelected]];

     } else if ([[segue identifier] isEqualToString:@"home_accept_decline_segue"]){
         
         AcceptDeclineController *vc = (AcceptDeclineController *)[segue destinationViewController];
         [vc setLocalMeeting:[_fetchedResultsController objectAtIndexPath:lastSelected]];
         
         
     } else if ([[segue identifier] isEqualToString:@"home_settings_segue"]){
         // to settings
         
     } else if ([[segue identifier] isEqualToString:@"home_final_segue"]){
         // to final location screen
         
         FinalViewController *vc = (FinalViewController *)[segue destinationViewController];
         PFQuery *query = [PFQuery queryWithClassName:@"Meeting"];
         NSError *error;
         PFObject *parseMeeting = [query getObjectWithId:[[_fetchedResultsController objectAtIndexPath:lastSelected] valueForKey:@"parse_object_id"] error:&error];
         if (!error) {
             [vc setParseMeeting:parseMeeting];
         }
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

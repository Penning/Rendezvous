//
//  HomeViewController.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCell.h"
#import "AppDelegate.h"
@interface HomeViewController : UIViewController

- (void)cellDoubleTapped:(HomeCell *)sender;
- (void)cellSingleTapped:(HomeCell *)sender;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)reloadMeetings;

@end

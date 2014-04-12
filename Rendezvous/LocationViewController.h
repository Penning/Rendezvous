//
//  LocationViewController.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/23/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "Meeting.h"
#import "ObservableMutableArray.h"

@interface LocationViewController : UIViewController

- (LocationViewController *) initWithMeeting:(PFObject *)meeting;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *finalizeLocationBtn;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ObservableMutableArray *suggestions;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) Meeting *meeting;
@property (strong, nonatomic) PFObject *parseMeeting;

- (IBAction)finalizeLocation:(id)sender;

@end

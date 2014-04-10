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

@interface LocationViewController : UIViewController

- (LocationViewController *) initWithMeeting:(PFObject *)meeting;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *suggestions;

@property (strong, nonatomic) Meeting *meeting;

@end

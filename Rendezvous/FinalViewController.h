//
//  FinalViewController.h
//  Rendezvous
//
//  Created by Adam Oxner on 4/11/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface FinalViewController : UIViewController

@property (strong, nonatomic) PFObject *parseMeeting;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *meetingNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *meetingAddressTextView;
@property (weak, nonatomic) IBOutlet UIView *underView;

@end

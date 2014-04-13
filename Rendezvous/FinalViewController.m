//
//  FinalViewController.m
//  Rendezvous
//
//  Created by Adam Oxner on 4/11/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "FinalViewController.h"

@interface FinalViewController ()

@end


@implementation FinalViewController{
    PFGeoPoint *geoPoint;
    NSString *placeName, *placeAddress;
    UIEdgeInsets mapInsets;
    MKPointAnnotation *mainAnnotation;
}

@synthesize parseMeeting = _parseMeeting;

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
    // Do any additional setup after loading the view.
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController.navigationBar.topItem setTitle:[_parseMeeting valueForKey:@"name"]];
    
    if (_parseMeeting) {
        PFObject *parseLocation = [_parseMeeting objectForKey:@"finalized_location"];
        
        
        // fetch location stuff
        [parseLocation fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            geoPoint = [parseLocation objectForKey:@"meeting_geopoint"];
            placeName = [parseLocation objectForKey:@"name"];
            placeAddress = [parseLocation objectForKey:@"address"];
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude)];
            annotation.title = placeName;
            annotation.subtitle = placeAddress;
            
            [_mapView addAnnotation:annotation];
            mainAnnotation = annotation;
            
            
            [self zoomToFitMapAnnotations];
        }];
    
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)zoomToFitMapAnnotations {
    if ([self.mapView.annotations count] == 0) return;
    
    int i = 0;
    MKMapPoint points[[self.mapView.annotations count]];
    
    //build array of annotation points
    for (id<MKAnnotation> annotation in [self.mapView annotations])
        points[i++] = MKMapPointForCoordinate(annotation.coordinate);
    
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:i];
    
    // zoom out 30%
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([poly boundingMapRect]);
    MKCoordinateSpan span;
    span.latitudeDelta= region.span.latitudeDelta *1.3;
    span.longitudeDelta= region.span.longitudeDelta *1.3;
    region.span=span;
    
    [self.mapView setRegion:region animated:YES];
}



- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (mainAnnotation) {
        [_mapView selectAnnotation:mainAnnotation animated:YES];
    }
}

- (IBAction)openInMapsBtnHit:(id)sender {
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:placeName];
    
    // Pass the map item to the Maps app
    [mapItem openInMapsWithLaunchOptions:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

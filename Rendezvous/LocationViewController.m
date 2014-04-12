//
//  LocationViewController.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/23/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "LocationViewController.h"
#import "LocationSuggestionsLookup.h"
#import "LocationSuggestionCell.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "AppDelegate.h"

@interface LocationViewController ()

@end

@implementation LocationViewController {
    LocationSuggestionsLookup *locationSuggestionsLookup;
    MKMapRect zoomRect;
    UIActivityIndicatorView *activityIndicator;
    PFGeoPoint *geoPoint;
    NSIndexPath *selectedIndex;
    CLGeocoder *geocoder;
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

- (LocationViewController *) initWithMeeting:(PFObject *)meeting{
    self = [super init];
    
    // do stuff
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) delayedReloadData {
    [self.tableView reloadData];
}

-(void) stopActivityIndicator {
    [activityIndicator stopAnimating];
}

-(void) annotateMap {
    zoomRect = MKMapRectNull;
    NSLog(@"Geocoding locations");

    geocoder = [[CLGeocoder alloc] init];

    //Add locations to map
    for(MeetingLocation *location in _suggestions) {
        NSString *address = [NSString stringWithFormat:@"%@, %@", location.streetAddress, location.city];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error){
            if(!error) {
                if (placemarks && placemarks.count > 0) {
                    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]];
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = placemark.coordinate;

                    location.pflocation = [[PFGeoPoint alloc] init];
                    location.pflocation.latitude = annotation.coordinate.latitude;
                    location.pflocation.longitude = annotation.coordinate.longitude;

                    annotation.title = location.name;
                    [_mapView addAnnotation:annotation];

                    //Add to zoom
                    [self zoomToFitMapAnnotations];
                }
            }
            else {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

- (void)zoomToFitMapAnnotations {
    [self.tableView reloadData];
    if ([self.mapView.annotations count] == 0) return;

    int i = 0;
    MKMapPoint points[[self.mapView.annotations count]];

    //build array of annotation points
    for (id<MKAnnotation> annotation in [self.mapView annotations])
        points[i++] = MKMapPointForCoordinate(annotation.coordinate);

    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:i];

    // zoom out 20%
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([poly boundingMapRect]);
    MKCoordinateSpan span;
    span.latitudeDelta= region.span.latitudeDelta *1.2;
    span.longitudeDelta= region.span.longitudeDelta *1.2;
    region.span=span;

    [self.mapView setRegion:region animated:YES];
}

- (void) sortData {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceFromLoc" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *temp = [_suggestions sortedArrayUsingDescriptors:sortDescriptors];
    [_suggestions removeAllObjects];
    [_suggestions addObjectsFromArray:temp];
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];

    [activityIndicator startAnimating];
    [self performSelector:@selector(delayedReloadData) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(sortData) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(stopActivityIndicator) withObject:nil afterDelay:0.5];

    //Map related
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self performSelector:@selector(annotateMap) withObject:nil afterDelay:1];
    
    // show navbar
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    // hide toolbar
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self performSelector:@selector(annotateMap)];
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
    // Return the number of rows in the section.
    return [_suggestions count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     LocationSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestion_cell"];
     if (cell == nil) {
         cell = [[LocationSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestion_cell"];
     }
 
     // Configure the cell...
     [cell initCellDisplay: [_suggestions objectAtIndex:indexPath.row] :[[_suggestions objectAtIndex:indexPath.row] category]];
     [cell.image setClipsToBounds:YES];

     return cell;
 }


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([selectedIndex isEqual:indexPath]) {
        selectedIndex = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        selectedIndex = indexPath;
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
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

- (IBAction)finalizeLocation:(id)sender {
    if(!selectedIndex) {
        return;
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Meeting"];
    [query whereKey:@"objectId" equalTo: [_meeting parseObjectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Do something with the found objects
            for (PFObject *object in objects) {
                PFObject *locationParse = [PFObject objectWithClassName:@"Location"];
                NSLog(@"%@", locationParse);
                MeetingLocation *location = [_suggestions objectAtIndex:selectedIndex.row];
                NSLog(@"%@", location);

                locationParse[@"name"] = location.name;

                if(!location.pflocation) {
                    NSString *address = [NSString stringWithFormat:@"%@, %@", location.streetAddress, location.city];
                    [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error){
                        if(!error) {
                            if (placemarks && placemarks.count > 0) {
                                MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]];
                                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                annotation.coordinate = placemark.coordinate;

                                location.pflocation = [[PFGeoPoint alloc] init];
                                location.pflocation.latitude = annotation.coordinate.latitude;
                                location.pflocation.longitude = annotation.coordinate.longitude;

                                annotation.title = location.name;
                                [_mapView addAnnotation:annotation];

                                //Add to zoom
                                [self zoomToFitMapAnnotations];
                            }
                        }
                        else {
                            NSLog(@"Error: %@", error);
                        }
                    }];
                }

                locationParse[@"meeting_geopoint"] = location.pflocation;

                [locationParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    object[@"finalized_location"] = locationParse;
                    [object saveInBackground];
                }];

            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    // unwind segue to home
    AppDelegate *appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [self.navigationController popToViewController:appDelegate.home animated:YES];
}

@end

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

@interface LocationViewController ()

@end

@implementation LocationViewController {
    LocationSuggestionsLookup *locationSuggestionsLookup;
}

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
//    [self.tableView reloadData];
//    NSLog(@"Suggestions: %@", suggestions);
}

-(void)delayedReloadData{
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
//    while([_suggestions count] == 0) {
//        [self.tableView reloadData];
//    }
//    [self performSelector:@selector(delayedReloadData) withObject:nil afterDelay:0.2];
//    locationSuggestionsLookup = [[LocationSuggestionsLookup alloc] init];
//    locationSuggestionsLookup.locationViewController = self;
//    Meeting *meeting = [[Meeting alloc] init]; 
//    [locationSuggestionsLookup getSuggestions:meeting];
//    _suggestions = [[NSMutableArray alloc] initWithArray:[locationSuggestionsLookup getSuggestionResults]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"NUMROWS: %ld", (long)[_suggestions count]);
    return [_suggestions count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     LocationSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestion_cell"];
     if (cell == nil) {
         cell = [[LocationSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestion_cell"];
     }
 
     // Configure the cell...
//     cell.name.text = [[_suggestions objectAtIndex:indexPath.row] name];
     [cell initCellDisplay: [_suggestions objectAtIndex:indexPath.row]];
     [cell.image setClipsToBounds:YES];

     return cell;
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

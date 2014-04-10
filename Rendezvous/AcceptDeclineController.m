//
//  AcceptDeclineController.m
//  Rendezvous
//
//  Created by Adam Oxner on 4/7/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "AcceptDeclineController.h"
#import "AppDelegate.h"

@interface AcceptDeclineController ()

@end

@implementation AcceptDeclineController{
    AppDelegate *appDelegate;
}

@synthesize parseMeeting = _parseMeeting;
@synthesize localMeeting = _localMeeting;

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
    
    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    
    if (!_parseMeeting) {
        _parseMeeting = [PFObject objectWithoutDataWithClassName:@"Meeting"
                                                                  objectId:[_localMeeting valueForKey:@"parse_object_id"]];
        
        // Fetch meeting object
        [_parseMeeting fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (!error) {
                [self.meetingTitleLabel setText:[_parseMeeting valueForKey:@"name"]];
            }
            
        }];
    }
    
    
    
    if (_localMeeting) {
        [self.meetingTitleLabel setText:[_localMeeting valueForKey:@"meeting_name"]];
    }
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptCurrentLocationBtnHit:(id)sender {
    
    // -------Parse location--------
    //
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (!error) {
            _parseMeeting[@"final_meeting_location"] = geoPoint;
            [_parseMeeting addUniqueObject:appDelegate.user.facebookID forKey:@"fb_ids_accepted_users"];
            [_parseMeeting incrementKey:@"num_responded"];
            [_parseMeeting saveInBackground];
        }else{
            NSLog(@"Location error: %@", error);
        }
        
    }];
    
    
    [self.navigationController popToViewController:appDelegate.home animated:YES];

}
- (IBAction)acceptNoLocationBtnHit:(id)sender {
    [_parseMeeting addUniqueObject:appDelegate.user.facebookID forKey:@"fb_ids_accepted_users"];
    [_parseMeeting incrementKey:@"num_responded"];
    [_parseMeeting saveInBackground];
    
    [self.navigationController popToViewController:appDelegate.home animated:YES];
}
- (IBAction)declineBtnHit:(id)sender {
    [_parseMeeting addUniqueObject:appDelegate.user.facebookID forKey:@"fb_ids_declined_users"];
    [_parseMeeting incrementKey:@"num_responded"];
    [_parseMeeting saveInBackground];
    
    [self.navigationController popToViewController:appDelegate.home animated:YES];
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

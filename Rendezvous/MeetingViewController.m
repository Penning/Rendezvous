//
//  MeetingViewController.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/22/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "MeetingViewController.h"

@interface MeetingViewController (){
    BOOL home;
}

@end

@implementation MeetingViewController

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
    if (home) {
        [self.nameLabel setHidden:NO];
        [self.nameTextField setHidden:YES];
        [self.sendContactsButton setTitle:@"Edit Contacts" forState:UIControlStateNormal];
    }else{
        [self.nameLabel setHidden:YES];
        [self.nameTextField setHidden:NO];
        [self.sendContactsButton setTitle:@"Send Invites" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initFromHome {
    home = true;
}

- (void)initFromContacts{
    home = false;
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

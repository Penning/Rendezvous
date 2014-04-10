//
//  LocationSuggestionCell.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/4/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingLocation.h"

@interface LocationSuggestionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UIImageView *categoryImage;

- (void)initCellDisplay:(MeetingLocation *) meeting :(NSString *) reason;

@end

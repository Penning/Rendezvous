//
//  LocationSuggestionCell.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/4/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "LocationSuggestionCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation LocationSuggestionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCellDisplay:(MeetingLocation *) meeting :(NSString *) reason {
    _name.text = meeting.name;
    _distance.text = [NSString stringWithFormat:@"%.2f mi", [meeting.distanceFromLoc doubleValue] * 0.000621371];
    _address.text = meeting.streetAddress;
    [_image setImageWithURL:[NSURL URLWithString:meeting.imageURL] placeholderImage:[UIImage imageNamed:@"111-user.png"]];

    if(![reason isEqualToString:@"None"]) {
        _categoryImage.bounds = CGRectMake(0, 0, 15, 15);
        [_categoryImage setImage:[UIImage imageNamed:reason]];
    }
}

@end

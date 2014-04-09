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

- (void)initCellDisplay:(MeetingLocation *) meeting {
    _name.text = meeting.name;
    _distance.text = [NSString stringWithFormat:@"%@", meeting.distanceFromLoc];
    _address.text = meeting.streetAddress;
//    if(meeting.imageURL) {
        [_image setImageWithURL:[NSURL URLWithString:meeting.imageURL] placeholderImage:[UIImage imageNamed:@"111-user.png"]];
//    }
}

@end

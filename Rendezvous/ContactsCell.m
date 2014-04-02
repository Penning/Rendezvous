//
//  ContactsCell.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "ContactsCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation ContactsCell

@synthesize contactName = _contactName;

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

- (void)initCellDisplay:(Friend *) fbFriend {
    _contactName.text = fbFriend.name;
    [_profilePicture setImageWithURL:fbFriend.pictureURL placeholderImage:[UIImage imageNamed:@"111-user.png"]];
}

- (void)initCellDisplayWithString:(NSString *) name {
    _contactName.text = name;
}

@end

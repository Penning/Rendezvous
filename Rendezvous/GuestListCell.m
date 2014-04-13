//
//  GuestListCell.m
//  Rendezvous
//
//  Created by Adam Oxner on 4/12/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "GuestListCell.h"

@implementation GuestListCell

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

@end

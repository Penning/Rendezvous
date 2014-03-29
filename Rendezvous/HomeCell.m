//
//  HomeCell.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/23/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "HomeCell.h"
#import "HomeViewController.h"

@implementation HomeCell

@synthesize parentController = _parentController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)initializeGestureRecognizer {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)doSingleTap:(UITapGestureRecognizer *)sender{
    if (_parentController != nil) {
        
        [((HomeViewController *)_parentController) cellSingleTapped:self];
    }
}

- (void)doDoubleTap:(UITapGestureRecognizer *)sender{
    if (_parentController != nil) {
        
        [((HomeViewController *)_parentController) cellDoubleTapped:self];
    }
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

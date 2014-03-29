//
//  Meeting.m
//  Rendezvous
//
//  Created by Adam Oxner on 3/29/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "Meeting.h"

@implementation Meeting{
    BOOL comeToMe;
}

@synthesize name = _name;
@synthesize description = _description;
@synthesize meeters = _meeters;

@synthesize acceptedMeeters = _acceptedMeeters;

- (id)init{
    self = [super init];
    
    comeToMe = NO;
    
    return self;
}

- (void)setComeToMe:(BOOL)option{
    comeToMe = option;
}

- (BOOL)isComeToMe{
    return comeToMe;
}

@end

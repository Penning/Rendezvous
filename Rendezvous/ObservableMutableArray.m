//
//  ObservableMutableArray.m
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/12/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import "ObservableMutableArray.h"

@implementation ObservableMutableArray
@synthesize delegate;

- (void)addObject:(id)anObject
{
    [super addObject:anObject];
    [delegate mutableArrayDidAddObject:self];
}
@end
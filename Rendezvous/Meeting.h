//
//  Meeting.h
//  Rendezvous
//
//  Created by Adam Oxner on 3/29/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meeting : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSArray *meeters;
@property (strong, nonatomic) NSMutableArray *reasons;

//Central location between meeters
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@property (strong, nonatomic) NSArray *locationSuggestions;

@property (readonly) NSArray *acceptedMeeters;

- (void)setComeToMe:(BOOL)option;
- (BOOL)isComeToMe;

@end

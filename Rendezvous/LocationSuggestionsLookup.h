//
//  LocationSuggestionsLookup.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/3/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meeting.h"
#import "LocationViewController.h"

@interface LocationSuggestionsLookup : NSObject

@property (strong, nonatomic) LocationViewController *locationViewController;

- (void) getSuggestions:(Meeting *) meeting;
- (NSArray *) getSuggestionResults;
- (NSInteger) suggestionCount;

@end

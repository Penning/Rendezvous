//
//  LocationSuggestionsLookup.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/3/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meeting.h"

@interface LocationSuggestionsLookup : NSObject

- (void) getSuggestions:(Meeting *) meeting;

@end

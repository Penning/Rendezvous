//
//  ObservableMutableArray.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 4/12/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MutableArrayDelegate
- (void)mutableArrayDidAddObject:(NSMutableArray *)mutableArray;
@end

@interface ObservableMutableArray : NSMutableArray
@property (nonatomic, assign) id<MutableArrayDelegate> delegate;
@end
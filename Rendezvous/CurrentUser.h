//
//  CurrentUser.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUser : NSObject

@property (nonatomic, strong) NSString *facebookID;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;

//Profile picture
@property (nonatomic, strong) NSURL *pictureURL;

@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *link;

//Friend Array
@property (nonatomic, strong) NSMutableArray *friends;

- (void) initFromRequest:(NSDictionary *) userData;

- (NSURL *) getPictureURL;

@end

//
//  Friend.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Friend : NSObject

@property (nonatomic, strong) NSString *facebookID;

//Profile picture
@property (nonatomic, strong) NSURL *pictureURL;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;

@property (nonatomic, strong) UIImageView *profile_picture;

- (Friend *) initWithObject:(NSDictionary<FBGraphUser>*) friend;
- (Friend *) initWithManagedObject:(NSManagedObject *) person;
- (NSURL *) getPictureURL;

@end

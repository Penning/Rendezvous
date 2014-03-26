//
//  ContactsCell.h
//  Rendezvous
//
//  Created by Sumedha Pramod on 3/25/14.
//  Copyright (c) 2014 Penning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

@interface ContactsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contactName;

- (void)initCellDisplay:(Friend *) fbFriend;
- (void)initCellDisplayWithString:(NSString *)name;

@end

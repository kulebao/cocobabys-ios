//
//  CSChildListItemTableViewCell.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-6.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSChildListItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labMessage;
@property (weak, nonatomic) IBOutlet UILabel *labNotification;
@property (weak, nonatomic) IBOutlet UIImageView *imgNewMsg;

@end

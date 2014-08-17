//
//  CSKuleChatingTableCell.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleTopicMsg.h"

@interface CSKuleChatingTableCell : UITableViewCell
@property (nonatomic, strong) CSKuleTopicMsg* msg;

- (void)tapHandle:(UITapGestureRecognizer *)tap;

@end

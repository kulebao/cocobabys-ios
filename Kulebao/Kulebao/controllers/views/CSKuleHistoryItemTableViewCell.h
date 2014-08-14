//
//  CSKuleHistoryItemTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityHistoryInfo.h"

@interface CSKuleHistoryItemTableViewCell : UITableViewCell

@property (nonatomic, strong) EntityHistoryInfo* historyInfo;

+ (CGFloat)calcHeight:(EntityHistoryInfo*)historyInfo;


@end

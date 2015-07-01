//
//  CSKuleHistoryItemTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityHistoryInfo.h"

@class CSKuleHistoryItemTableViewCell;

@protocol CSKuleHistoryItemTableViewCellDelegate <NSObject>

@optional
- (void)historyItemTableCellDidLongPress:(CSKuleHistoryItemTableViewCell*)cell;

@end

@interface CSKuleHistoryItemTableViewCell : UITableViewCell

@property (nonatomic, strong) EntityHistoryInfo* historyInfo;
@property (nonatomic, weak) id delegate;

+ (CGFloat)calcHeight:(EntityHistoryInfo*)historyInfo;
- (IBAction)onBtnShareClicked:(id)sender;


@end

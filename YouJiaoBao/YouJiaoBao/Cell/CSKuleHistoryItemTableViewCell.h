//
//  CSKuleHistoryItemTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBHistoryInfo.h"

@class CSKuleHistoryItemTableViewCell;

@protocol CSKuleHistoryItemTableViewCellDelegate <NSObject>

@optional
- (void)historyItemTableCellDidLongPress:(CSKuleHistoryItemTableViewCell*)cell;

@end

@interface CSKuleHistoryItemTableViewCell : UITableViewCell

@property (nonatomic, strong) CBHistoryInfo* historyInfo;
@property (nonatomic, weak) id delegate;

+ (CGFloat)calcHeight:(CBHistoryInfo*)historyInfo width:(CGFloat)width;
- (IBAction)onBtnShareClicked:(id)sender;


@end

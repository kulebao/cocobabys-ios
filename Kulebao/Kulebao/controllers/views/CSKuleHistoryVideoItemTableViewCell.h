//
//  CSKuleHistoryVideoItemTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 15/3/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityHistoryInfoHelper.h"

@class CSKuleHistoryVideoItemTableViewCell;

@protocol CSKuleHistoryVideoItemTableViewCellDelegate <NSObject>

@optional
- (void)historyVideoItemTableCellDidLongPress:(CSKuleHistoryVideoItemTableViewCell*)cell;

@end

@interface CSKuleHistoryVideoItemTableViewCell : UITableViewCell

@property (nonatomic, strong) EntityHistoryInfo* historyInfo;
@property (nonatomic, weak) id delegate;

+ (CGFloat)calcHeight:(EntityHistoryInfo*)historyInfo width:(CGFloat)width;;
- (IBAction)onBtnShareClicked:(id)sender;

@end

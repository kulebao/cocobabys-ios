//
//  CSKuleHistoryVideoItemTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 15/3/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBHistoryInfo.h"

@class CSKuleHistoryVideoItemTableViewCell;

@protocol CSKuleHistoryVideoItemTableViewCellDelegate <NSObject>

@optional
- (void)historyVideoItemTableCellDidLongPress:(CSKuleHistoryVideoItemTableViewCell*)cell;

@end

@interface CSKuleHistoryVideoItemTableViewCell : UITableViewCell

@property (nonatomic, strong) CBHistoryInfo* historyInfo;
@property (nonatomic, weak) id delegate;

+ (CGFloat)calcHeight:(CBHistoryInfo*)historyInfo width:(CGFloat)width;;
- (IBAction)onBtnShareClicked:(id)sender;

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end

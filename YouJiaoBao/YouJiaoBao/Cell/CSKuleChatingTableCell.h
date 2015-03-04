//
//  CSKuleChatingTableCell.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityTopicMsgHelper.h"

@class CSKuleChatingTableCell;

@protocol CSKuleChatingTableCellDelegate <NSObject>

@optional
- (void)chatingTableCell:(CSKuleChatingTableCell*)cell playVoice:(EntityTopicMsg*)msg;
- (void)chatingTableCellDidLongPress:(CSKuleChatingTableCell*)cell;

@end

@interface CSKuleChatingTableCell : UITableViewCell

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) EntityTopicMsg* msg;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGes;
@property (nonatomic, strong) UITapGestureRecognizer* tapGes;

+ (CGFloat)calcHeightForMsg:(EntityTopicMsg*)msg;
+ (CGSize)textSize:(NSString*)text;

- (void)tapHandle:(UITapGestureRecognizer *)tap;
- (void)tapVoiceHandle:(UITapGestureRecognizer *)tap;
- (void)longPressHandle:(UILongPressGestureRecognizer*)ges;


@end

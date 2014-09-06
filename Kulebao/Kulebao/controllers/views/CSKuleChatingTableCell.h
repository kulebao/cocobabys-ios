//
//  CSKuleChatingTableCell.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleTopicMsg.h"

@class CSKuleChatingTableCell;

@protocol CSKuleChatingTableCellDelegate <NSObject>

@optional
- (void)chatingTableCell:(CSKuleChatingTableCell*)cell playVoice:(CSKuleTopicMsg*)msg;

@end

@interface CSKuleChatingTableCell : UITableViewCell

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) CSKuleTopicMsg* msg;

+ (CGFloat)calcHeightForMsg:(CSKuleTopicMsg*)msg;
+ (CGSize)textSize:(NSString*)text;

- (void)tapHandle:(UITapGestureRecognizer *)tap;
- (void)tapVoiceHandle:(UITapGestureRecognizer *)tap;
- (void)longPressHandle:(UILongPressGestureRecognizer*)ges;


@end

//
//  UIViewController+CSKit.h
//  CSKit
//
//  Created by xin.c.wang on 14-3-9.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CSKit)


- (void)customizeLeftBarItemWithTarget:(id)target action:(SEL)action normal:(UIImage*)imgNormal hightlight:(UIImage*)imgHighlight;

- (void)customizeRightBarItemWithTarget:(id)target action:(SEL)action normal:(UIImage*)imgNormal hightlight:(UIImage*)imgHighlight text:(NSString*)text;

- (void)customizeBackBarItemWithTarget:(id)target action:(SEL)action;
- (void)customizeBackBarItem;

- (void)customizeOkBarItemWithTarget:(id)target action:(SEL)action text:(NSString*)text;

@end

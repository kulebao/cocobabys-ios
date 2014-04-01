//
//  UIWebView+CSKit.m
//  CSKit
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#import "UIWebView+CSKit.h"

@implementation UIWebView (CSKit)

- (void)hideGradientBackground {
    self.opaque = NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    for (UIView *subView in [self subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView *shadowView in [subView subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    shadowView.hidden = YES;
                }
            }
        }
    }
}

@end

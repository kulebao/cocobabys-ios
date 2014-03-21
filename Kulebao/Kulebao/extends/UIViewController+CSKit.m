//
//  UIViewController+CSKit.m
//  CSKit
//
//  Created by xin.c.wang on 14-3-9.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "UIViewController+CSKit.h"

@implementation UIViewController (CSKit)

- (void)customizeLeftBarItemWithTarget:(id)target action:(SEL)action normal:(UIImage*)imgNormal hightlight:(UIImage*)imgHighlight {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:imgHighlight forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(0, 0, imgNormal.size.width, imgNormal.size.height);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = btnItem;
}

- (void)customizeRightBarItemWithTarget:(id)target action:(SEL)action normal:(UIImage*)imgNormal hightlight:(UIImage*)imgHighlight text:(NSString*)text{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:imgHighlight forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, imgNormal.size.width, imgNormal.size.height);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    self.navigationItem.rightBarButtonItem = btnItem;
}

- (void)customizeBackBarItemWithTarget:(id)target action:(SEL)action {
    UIImage* imgNormal = [UIImage imageNamed:@"btn-back1.png"];
    UIImage* imgHighlight = [UIImage imageNamed:@"btn-back1-pressed.png"];
    
    [self customizeLeftBarItemWithTarget:target
                                  action:action
                                  normal:imgNormal
                              hightlight:imgHighlight];
}

- (void)customizeBackBarItem {
    [self customizeBackBarItemWithTarget:self action:@selector(onBtnBackClicked_CSKit:)];
}

- (void)customizeOkBarItemWithTarget:(id)target action:(SEL)action text:(NSString*)text {
    UIImage* imgNormal = [UIImage imageNamed:@"btn-type1.png"];
    UIImage* imgHighlight = [UIImage imageNamed:@"btn-type1-pressed.png"];
    [self customizeRightBarItemWithTarget:target action:action normal:imgNormal hightlight:imgHighlight text:text];
}

#pragma mark - UI Actions
- (void)onBtnBackClicked_CSKit:(id)sender {
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
@end

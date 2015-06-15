//
//  UIViewController+CSKit.m
//  CSKit
//
//  Created by xin.c.wang on 14-3-9.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#import "UIViewController+CSKit.h"

@implementation UIViewController (CSKit)

- (void)customizeLeftBarItemWithTarget:(id)target action:(SEL)action normal:(UIImage*)imgNormal hightlight:(UIImage*)imgHighlight {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:imgHighlight forState:UIControlStateHighlighted];
    //btn.frame = CGRectMake(0, 0, imgNormal.size.width, imgNormal.size.height);
    btn.frame = CGRectMake(0, 0, 44, 24);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = btnItem;
}

- (void)customizeRightBarItemWithTarget:(id)target action:(SEL)action normal:(UIImage*)imgNormal hightlight:(UIImage*)imgHighlight text:(NSString*)text{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:imgHighlight forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 44, 24);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn sizeToFit];
    self.navigationItem.rightBarButtonItem = btnItem;
}

- (void)customizeBackBarItemWithTarget:(id)target action:(SEL)action {
    UIImage* imgNormal = [UIImage imageNamed:@"v2-btn_back.png"];
    UIImage* imgHighlight = nil;
    
    [self customizeLeftBarItemWithTarget:target
                                  action:action
                                  normal:imgNormal
                              hightlight:imgHighlight];
}

- (void)customizeBackBarItem {
    [self customizeBackBarItemWithTarget:self action:@selector(onBtnBackClicked_CSKit:)];
}

- (void)customizeOkBarItemWithTarget:(id)target action:(SEL)action text:(NSString*)text {
    UIImage* imgNormal = nil;
    UIImage* imgHighlight = nil;
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

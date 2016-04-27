// UIViewController+CSKit.m
//
// Copyright (c) 2014-2016 Xinus Wang. All rights reserved.
// https://github.com/xinus/CSKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIViewController+CSKit.h"

@implementation UIViewController (CSKit)

- (void)customizeLeftBarItemWithTarget:(id)target
                                action:(SEL)action
                                normal:(UIImage*)imgNormal
                            hightlight:(UIImage*)imgHighlight {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:imgHighlight forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(0, 0, imgNormal.size.width, imgNormal.size.height);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = btnItem;
}

- (void)customizeRightBarItemWithTarget:(id)target
                                 action:(SEL)action
                                 normal:(UIImage*)imgNormal
                             hightlight:(UIImage*)imgHighlight
                                   text:(NSString*)text{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:imgHighlight forState:UIControlStateHighlighted];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, imgNormal.size.width, imgNormal.size.height);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.navigationItem.rightBarButtonItem = btnItem;
}

- (void)customizeBackBarItemWithTarget:(id)target action:(SEL)action {
//#warning use your own background images for nav-back button.
    UIImage* imgNormal = [UIImage imageNamed:@"btn-nav-back.png"];
    UIImage* imgHighlight = [UIImage imageNamed:@"btn-nav-back-pressed.png"];
    
    [self customizeLeftBarItemWithTarget:target
                                  action:action
                                  normal:imgNormal
                              hightlight:imgHighlight];
}

- (void)customizeBackBarItem {
    [self customizeBackBarItemWithTarget:self action:@selector(onBtnBackClicked_CSKit:)];
}

- (void)customizeOkBarItemWithTarget:(id)target action:(SEL)action text:(NSString*)text {
//#warning use your own background images for nav-right button.
    UIImage* imgNormal = [UIImage imageNamed:@"btn-nav-right.png"];
    UIImage* imgHighlight = [UIImage imageNamed:@"btn-nav-right-pressed.png"];
    [self customizeRightBarItemWithTarget:target action:action normal:imgNormal hightlight:imgHighlight text:text];
}

#pragma mark - UI Actions
- (void)onBtnBackClicked_CSKit:(id)sender {
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

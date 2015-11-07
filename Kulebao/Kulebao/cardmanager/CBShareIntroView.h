//
//  CBShareIntroView.h
//  youlebao
//
//  Created by xin.c.wang on 11/6/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBShareIntroView : UIView
- (IBAction)onBtnBgClicked:(id)sender;
- (IBAction)onBtnShareClicked:(id)sender;

- (void)showInView:(UIView*)view;

+ (id)instance;

@end

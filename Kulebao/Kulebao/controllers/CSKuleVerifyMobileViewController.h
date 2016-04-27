//
//  CSKuleVerifyMobileViewController.h
//  youlebao
//
//  Created by xin.c.wang on 14-4-3.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSKuleVerifyMobileViewController : UIViewController

@property (nonatomic, strong) NSString* mobile;
@property (nonatomic, weak) id delegate;

@end

@protocol CSKuleVerifyMobileViewControllerDelegate <NSObject>

@optional
- (void)verifyMobileViewControllerDidFinished:(CSKuleVerifyMobileViewController*)ctrl;

@end

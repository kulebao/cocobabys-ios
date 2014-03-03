//
//  CSAppDelegate.h
//  Kulebao
//
//  Created by xin.c.wang on 14-2-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleEngine.h"

@interface CSAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CSKuleEngine* engine;

// -
- (void)gotoLoginProcess;
- (void)gotoMainProcess;

@end


extern CSAppDelegate* gApp;
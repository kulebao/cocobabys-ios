//
//  CSAppDelegate.h
//  Kulebao
//
//  Created by xin.c.wang on 14-2-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleEngine.h"
#import "MBProgressHUD.h"

@interface CSAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CSKuleEngine* engine;
@property (strong, nonatomic) MBProgressHUD* hud;

// -
- (void)gotoLoginProcess;
- (void)gotoMainProcess;
- (void)logout;

// - Alert
- (void)alert:(NSString*)text;
- (void)alert:(NSString*)text withTitle:(NSString*)title;
- (void)waitingAlert:(NSString*)text;
- (void)waitingAlert:(NSString*)text withTitle:(NSString*)title;

- (void)hideAlert;
- (void)hideAlertAfterDelay:(NSTimeInterval)delay;

@end


extern CSAppDelegate* gApp;
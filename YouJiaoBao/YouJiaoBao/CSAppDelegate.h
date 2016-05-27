//
//  CSAppDelegate.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-5.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MBProgressHUD* hud;


+ (CSAppDelegate*)sharedInstance;


// - Alert
- (void)shortAlert:(NSString*)text;
- (void)alert:(NSString*)text;
- (void)alert:(NSString*)text withTitle:(NSString*)title;
- (void)waitingAlert:(NSString*)text;
- (void)waitingAlert:(NSString*)text withTitle:(NSString*)title;
- (void)hideAlert;
- (void)hideAlertAfterDelay:(NSTimeInterval)delay;

@end


extern CSAppDelegate* gApp;
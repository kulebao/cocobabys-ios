//
//  CSAppDelegate.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-5.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CSCoreDataHelper.h"
#import "CSEngine.h"

CSAppDelegate* gApp = nil;

@implementation CSAppDelegate
@synthesize hud = _hud;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[CSEngine sharedInstance] setupAppearance];
    
    gApp = self;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"app.applicationWillResignActive" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[CSCoreDataHelper sharedInstance] saveContext];
}

#pragma mark - Instance
+ (CSAppDelegate*)sharedInstance {
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark - Alert
- (BOOL)createHudIfNeeded {
    BOOL ok = NO;
    
    if (self.window) {
        if (_hud == nil) {
            _hud = [[MBProgressHUD alloc] initWithWindow:self.window];
            _hud.color = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            [self.window addSubview:_hud];
        }
        ok = YES;
    }
    
    return ok;
}
- (void)alert:(NSString*)text {
    [self alert:text withTitle:nil];
}

- (void)alert:(NSString*)text withTitle:(NSString*)title {
    if ([self createHudIfNeeded]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.hud];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = title;
        self.hud.detailsLabelText = text;
        [_window bringSubviewToFront:self.hud];
        [self.hud show:YES];
        [self hideAlertAfterDelay:1.5];
    }
}

- (void)waitingAlert:(NSString*)text {
    [self waitingAlert:text withTitle:nil];
}

- (void)waitingAlert:(NSString*)text withTitle:(NSString*)title {
    if ([self createHudIfNeeded]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.hud];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = title;
        self.hud.detailsLabelText = text;
        [_window bringSubviewToFront:self.hud];
        [self.hud show:YES];
        [self hideAlertAfterDelay:60];
    }
}

- (void)hideAlert {
    [self hideAlertAfterDelay:0.3];
}

- (void)hideAlertAfterDelay:(NSTimeInterval)delay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self.hud];
    [self.hud hide:YES afterDelay:delay];
}


@end

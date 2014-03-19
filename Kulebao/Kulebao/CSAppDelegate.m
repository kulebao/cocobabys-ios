//
//  CSAppDelegate.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSAppDelegate.h"
CSAppDelegate* gApp = nil;

@implementation CSAppDelegate
@synthesize engine = _engine;
@synthesize hud = _hud;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    gApp = self;
    _engine = [[CSKuleEngine alloc] init];
    [_engine setupEngine];
    
    return [_engine application:application didFinishLaunchingWithOptions:launchOptions];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [_engine applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [_engine applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [_engine applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_engine applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_engine applicationWillTerminate:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [_engine application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_engine application:application didReceiveRemoteNotification:userInfo];
}

#pragma mark - Private
- (void)gotoLoginProcess {
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id ctrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"CSLoginNavigationController"];
    gApp.window.rootViewController = ctrl;
}

- (void)gotoMainProcess {
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id ctrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"CSMainNavigationController"];
    gApp.window.rootViewController = ctrl;
}

- (void)logout {
    gApp.engine.loginInfo = nil;
    gApp.engine.relationships = nil;
    gApp.engine.currentRelationship = nil;
    gApp.engine.preferences.loginInfo = nil;
    
    [self gotoLoginProcess];
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

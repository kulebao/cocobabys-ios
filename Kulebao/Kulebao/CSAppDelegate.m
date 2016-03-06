//
//  CSAppDelegate.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSAppDelegate.h"
#import "BPush.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"
#import <Bugly/CrashReporter.h>
#import "CBIMDataSource.h"
#import "CBSessionDataModel.h"

#define RONGCLOUD_IM_APPKEY @"0vnjpoadnwk0z"

CSAppDelegate* gApp = nil;

@interface CSAppDelegate () <EAIntroDelegate>

@end

@implementation CSAppDelegate
@synthesize engine = _engine;
@synthesize hud = _hud;
@synthesize isPlayView = _isPlayView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    gApp = self;
    
    // 初始化Bugly
    // [[CrashReporter sharedInstance] enableLog:YES];
    [[CrashReporter sharedInstance] installWithAppId:@"900013148"];
    // [self performSelector:@selector(crash) withObject:nil afterDelay:3.0];
    
    // 初始化融云
    CSKulePreferences* preference = [CSKulePreferences defaultPreferences];
    NSDictionary* configInfo = [preference getServerSettings];
    [[RCIM sharedRCIM] initWithAppKey:configInfo[@"rongyun_app_id"]];
    [[RCIM sharedRCIM] setGroupInfoDataSource:[CBIMDataSource sharedInstance]];
    [[RCIM sharedRCIM] setUserInfoDataSource:[CBIMDataSource sharedInstance]];
    [[RCIM sharedRCIM] setGroupUserInfoDataSource:[CBIMDataSource sharedInstance]];
    // [[RCIM sharedRCIM] setReceiveMessageDelegate:[CBIMDataSource sharedInstance]];
    
    _engine = [[CSKuleEngine alloc] init];
    [_engine setupEngine];
    
    return [_engine application:application didFinishLaunchingWithOptions:launchOptions];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    [session store];
    
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

#ifdef __IPHONE_8_0
- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // 打印到日志
    CSLog(@"backgroud : %@",userInfo);
    
    if (application.applicationState == UIApplicationStateActive) {
    }
    else {
        _engine.badgeOfCheckin = _engine.badgeOfCheckin + 1;
        [application setApplicationIconBadgeNumber:0];
        
        if (userInfo) {
            _engine.pendingNotificationInfo = userInfo;
        }
    }
    
    if (userInfo) {
        [_engine.receivedNotifications addObject:userInfo];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    
    [_engine application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_engine application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [_engine application:application didReceiveLocalNotification:notification];
}

// 当 DeviceToken 获取失败时,系统会回调此⽅方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败,原因:%@",error);
}

#pragma mark - Private
- (void)gotoLoginProcess {    
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id ctrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"CSLoginNavigationController"];
    gApp.window.rootViewController = ctrl;
    
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    [session invalidate];
    
    [self showIntroViewsIfNeeded];
}

- (void)gotoMainProcess {
    if (gApp.engine.loginInfo) {
        NSDictionary* serverInfo = [gApp.engine.preferences getServerSettings];
        [CBSessionDataModel session:gApp.engine.loginInfo.accountName withTag:serverInfo[@"tag"]];
        
        if (gApp.engine.loginInfo.imToken) {
            // 快速集成第二步，连接融云服务器
            [[RCIM sharedRCIM] connectWithToken:gApp.engine.loginInfo.imToken.token
                                        success:^(NSString *userId) {
                                            // Connect 成功
                                            CSLog(@"[RCIM] connect success.");
                                        } error:^(RCConnectErrorCode status) {
                                            // Connect 失败
                                            CSLog(@"[RCIM] connect error.");
                                        } tokenIncorrect:^() {
                                            // Token 失效的状态处理
                                            CSLog(@"[RCIM] connect tokenIncorrect.");
                                        }];
        }
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        id ctrl = [mainStoryboard instantiateViewControllerWithIdentifier:@"CSMainNavigationController"];
        gApp.window.rootViewController = ctrl;
        [self showIntroViewsIfNeeded];
    }
    else {
        CBSessionDataModel* session = [CBSessionDataModel thisSession];
        [session invalidate];
    }
}

- (void)logout {
    self.engine.loginInfo = nil;
    self.engine.relationships = nil;
    self.engine.currentRelationship = nil;
    self.engine.preferences.loginInfo = nil;
    
    [[RCIM sharedRCIM] disconnect:NO];
    
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

- (void)shortAlert:(NSString*)text {
    if ([self createHudIfNeeded]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.hud];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = nil;
        self.hud.detailsLabelText = text;
        [_window bringSubviewToFront:self.hud];
        [self.hud show:YES];
        [self hideAlertAfterDelay:1];
    }
}

- (void)alert:(NSString*)text withTitle:(NSString*)title {
    if ([self createHudIfNeeded]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.hud];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = title;
        self.hud.detailsLabelText = text;
        [_window bringSubviewToFront:self.hud];
        [self.hud show:YES];
        [self hideAlertAfterDelay:1];
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

- (void)alertNoChild {
    [gApp alert:@"获取幼儿信息失败，请联系幼儿园确认幼儿信息已经绑定，且网络正常后，重新启动应用！"];
}

#pragma mark - Private
- (void)showIntroViewsIfNeeded {
    if (!gApp.engine.preferences.guideShown) {
        [self showIntroViews];
    }
    else {
    }
}

-(void)showIntroViews {
    //float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    /*
     NSArray* introImageNames = @[@"guide-1.png", @"guide-2.png", @"guide-3.png", @"guide-4.png"];
     if (!IS_IPHONE4) {
     introImageNames = @[@"guide-1-568h.png", @"guide-2-568h.png", @"guide-3-568h.png", @"guide-4-568h.png"];
     }
     */
    NSArray* introImageNames = @[@"v2_8-guide-1", @"v2_8-guide-2"];
    
    NSMutableArray* introPages = [NSMutableArray array];
    for (NSString* imageName in introImageNames) {
        UIImage* img = [UIImage imageNamed:imageName];
        if (img) {
            EAIntroPage* page = [EAIntroPage page];
            UIImageView* imageV = [[UIImageView alloc] initWithFrame:self.window.rootViewController.view.bounds];
            imageV.image = img;
            page.customView = imageV;
            [introPages addObject:page];
        }
        else {
            CSLog(@"Load Image Failed: %@", imageName);
        }
    }
    
    if (introPages.count > 0) {
        UIButton* skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[skipButton setBackgroundImage:[UIImage imageNamed:@"btn-start.png"] forState:UIControlStateNormal];
        //[skipButton setBackgroundImage:[UIImage imageNamed:@"btn-start-pressed.png"] forState:UIControlStateHighlighted];
        
        CGSize viewSize = self.window.rootViewController.view.bounds.size;
        //skipButton.frame = CGRectMake((viewSize.width-126)/2, viewSize.height-90, 126, 27);
        skipButton.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
        
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.window.rootViewController.view.bounds
                                                       andPages:introPages];
        intro.skipButton = skipButton;
        intro.backgroundColor = [UIColor whiteColor];
        intro.scrollView.bounces = NO;
        intro.swipeToExit = NO;
        intro.easeOutCrossDisolves = NO;
        intro.showSkipButtonOnlyOnLastPage = YES;
        intro.pageControl.hidden = YES;
        [intro setDelegate:self];
        [intro showInView:self.window.rootViewController.view animateDuration:0];
    }
}

#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
    gApp.engine.preferences.guideShown = YES;
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}
@end

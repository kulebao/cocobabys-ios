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
#import "CSFirImApi.h"
#import <objc/runtime.h>
#import <Bugly/CrashReporter.h>
#import <RongIMKit/RongIMKit.h>
#import "CBIMDataSource.h"
#import "CBIMChatViewController.h"
#import <BlocksKit/BlocksKit.h>

CSAppDelegate* gApp = nil;

@implementation CSAppDelegate {
    BOOL _checkUpdateDone;
    UIAlertView* _alertUpdateInfo;
    
    NSMutableArray* _receivedNotifications;
    NSData* _deviceToken;
    NSDictionary* _pendingNotificationInfo;
}



@synthesize hud = _hud;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    //[[CrashReporter sharedInstance] enableLog:YES];
    [[CrashReporter sharedInstance] installWithAppId:@"900013150"];
    //[self performSelector:@selector(crash) withObject:nil afterDelay:3.0];
    
    // 初始化融云
    [[RCIM sharedRCIM] initWithAppKey:COCOBABYS_IM_APP_ID];
    [[RCIM sharedRCIM] setGroupInfoDataSource:[CBIMDataSource sharedInstance]];
    [[RCIM sharedRCIM] setUserInfoDataSource:[CBIMDataSource sharedInstance]];
    [[RCIM sharedRCIM] setGroupUserInfoDataSource:[CBIMDataSource sharedInstance]];
    
    //
    id naviAppearance = [UINavigationBar appearance];
    //[naviAppearance setBackgroundImage:[UIImage imageNamed:@"v2-head.png"] forBarMetrics:UIBarMetricsDefault];
    [naviAppearance setBarTintColor:UIColorRGB(0, 164, 217)];
    [naviAppearance setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //naviAppearance.tintColor = [UIColor whiteColor];
    [naviAppearance setTintColor:[UIColor whiteColor]];
    
    _receivedNotifications = [NSMutableArray array];
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }

    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self application:application onRemotePushNotification:userInfo launching:YES];
    }
    
    // 本地通知的内容
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self application:application onLocalNotification:localNotification launching:YES];
    }
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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
#if COCOBABYS_CHECK_UPDATE_FROM_FIR
    NSString* versionShort = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [CSFirImApi getLatestAppInfo:@"54187a75f9420736590002b2"
                        apiToken:@"f33fee2cc37b3ad7d6f787176893e89d" complete:^(FirImAppInfoData *appInfoData, NSError *error) {
                            if (appInfoData && !error) {
                                //appInfoData.versionShort = @"10.0.0";
                                //appInfoData.build = @"180827";
                                if (![appInfoData.versionShort isEqualToString:versionShort]
                                    && appInfoData.build.integerValue > build.integerValue
                                    && !_checkUpdateDone
                                    && !_alertUpdateInfo) {
                                    NSString* alertTitle = [[NSString alloc] initWithFormat:@"发现新内测版本 v%@", appInfoData.versionShort];
                                    NSString* alertMsg = [NSString stringWithFormat:@"更新日志：\r\n%@", appInfoData.changelog];
                                    _alertUpdateInfo = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                                  message:alertMsg
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"知道了"
                                                                        otherButtonTitles:@"去看看", nil];
                                    objc_setAssociatedObject(_alertUpdateInfo, "FirImAppInfoData", appInfoData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                    [_alertUpdateInfo show];
                                }
                            }
                        }];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[CSCoreDataHelper sharedInstance] saveContext];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    CSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", deviceToken);
    _deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    CSLog(@"%@", @"Did receive a Remote Notification");
    [self application:application onRemotePushNotification:userInfo launching:NO];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self application:application onLocalNotification:notification launching:NO];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([_alertUpdateInfo isEqual:alertView]) {
        if (buttonIndex==alertView.firstOtherButtonIndex) {
            FirImAppInfoData* appInfo = objc_getAssociatedObject(alertView, "FirImAppInfoData");
            objc_removeAssociatedObjects(alertView);
            _checkUpdateDone = YES;
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appInfo.update_url]];
        }
        
        _alertUpdateInfo = nil;
    }
}

#pragma mark - Remote/Local Notification
- (void)application:(UIApplication *)application onRemotePushNotification:(NSDictionary*)userInfo launching:(BOOL)yes {
    if (yes) {
        CSLog(@"从推送消息启动:%@", userInfo);
        [_receivedNotifications addObject:userInfo];
        _pendingNotificationInfo = userInfo;
    }
    else {
        CSLog(@"收到推送消息:%@", userInfo);
        
        if (application.applicationState == UIApplicationStateActive) {
            NSDictionary * rcData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
            if (rcData == nil) {
                [application setApplicationIconBadgeNumber:0];
            }
        }
        else {
            if (userInfo) {
                _pendingNotificationInfo = userInfo;
            }
        }
        
        if (userInfo) {
            [_receivedNotifications addObject:userInfo];
        }
    }
}

- (void)application:(UIApplication *)application onLocalNotification:(UILocalNotification*)notification launching:(BOOL)yes {
    if (yes) {
        CSLog(@"从本地消息启动:%@", notification);
    }
    else {
        CSLog(@"收到本地消息:%@", notification);
        NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:notification.userInfo];
        if (pushServiceData) {
        }
    }
    _pendingNotificationInfo = notification.userInfo;
}

@end

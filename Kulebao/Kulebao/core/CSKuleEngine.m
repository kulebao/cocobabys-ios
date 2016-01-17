//
//  CSKuleEngine.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleEngine.h"
#import "CSAppDelegate.h"
#import "AHAlertView.h"
#import "BPush.h"
#import "BaiduMobStat.h"
#import "CSKuleURLCache.h"
#import "ALAlertBannerManager.h"
#import "ALAlertBanner+Private.h"
#import "hm_sdk.h"
#import "TSFileCache.h"
#import "CSKit.h"
#import "CSKulePreferences.h"

#import <objc/runtime.h>
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import "CSFirImApi.h"


@interface CSKuleEngine() <UIAlertViewDelegate> {
    NSMutableDictionary* _senderProfiles;
    BMKMapManager* _mapManager;
    
    BOOL _checkUpdateDone;
    UIAlertView* _alertUpdateInfo;
}

//数据模型对象
@property(strong,nonatomic) NSManagedObjectModel* managedObjectModel;
//上下文对象
@property(strong,nonatomic) NSManagedObjectContext* managedObjectContext;
//持久性存储区
@property(strong,nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation CSKuleEngine
@synthesize preferences = _preferences;
@synthesize loginInfo = _loginInfo;
@synthesize relationships = _relationships;
@synthesize currentRelationship = _currentRelationship;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize badgeOfNews = _badgeOfNews;
@synthesize badgeOfRecipe = _badgeOfRecipe;
@synthesize badgeOfCheckin = _badgeOfCheckin;
@synthesize badgeOfSchedule = _badgeOfSchedule;
@synthesize badgeOfAssignment = _badgeOfAssignment;
@synthesize badgeOfChating = _badgeOfChating;
@synthesize badgeOfAssess = _badgeOfAssess;

@synthesize hmServerId = _hmServerId;
@synthesize receivedNotifications = _receivedNotifications;

#pragma mark - application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    CSLog(@"%f Launched.", [[NSDate date] timeIntervalSince1970]*1000);
    
    // 添加百度统计
    [self setupBaiduMobStat];
    
    // ShareSDK
    [self setupShareSDK];
    
    // 添加百度地图
    _mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"oGpNadkf2d8od1xoFMUnnRmx"  generalDelegate:nil];
    if (!ret) {
        CSLog(@"BMKMapManager start failed!");
    }
    self.locService = [[BMKLocationService alloc] init];
    
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    CSKulePreferences* preference = [CSKulePreferences defaultPreferences];
    NSDictionary* serverInfo = [preference getServerSettings];
    
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    NSInteger bdPushModel = BPushModeProduction;
#ifdef DEBUG
    bdPushModel = BPushModeDevelopment;
#endif
    
    [BPush registerChannel:launchOptions
                    apiKey:serverInfo[@"baidu_api_key"]
                  pushMode:bdPushModel
           withFirstAction:nil
          withSecondAction:nil
              withCategory:nil
                   isDebug:NO];

    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self onRemotePushNotification:userInfo launching:YES];
    }
    
    // 本地通知的内容
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [self onLocalNotification:localNotification launching:YES];
    }
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[CSKulePreferences defaultPreferences] savePreferences];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"app.applicationWillResignActive" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSArray* banners = [[ALAlertBannerManager sharedManager] alertBannersInView:gApp.window];
    for (ALAlertBanner* banner in banners) {
        [banner hideAlertBanner];
    }

    CSKuleChildInfo* currentChild = _currentRelationship.child;
    if (currentChild) {
        if ([self.loginInfo.memberStatus isEqualToString:@"free"]) {
            [self checkUpdatesOfNews];
            [self checkUpdatesOfCheckin];
        }
        else if ([self.loginInfo.memberStatus isEqualToString:@"paid"]) {
            [self checkUpdatesOfNews];
            [self checkUpdatesOfRecipe];
            [self checkUpdatesOfCheckin];
            [self checkUpdatesOfSchedule];
            //[self checkUpdatesOfAssignment];
            //[self checkUpdatesOfChating];
            [self checkUpdatesOfAssess];
        }
    }
    
#if COCOBABYS_CHECK_UPDATE_FROM_FIR
    NSString* versionShort = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [CSFirImApi getLatestAppInfo:@"540b29930a99448660000086"
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([_alertUpdateInfo isEqual:alertView]) {
        if (buttonIndex==alertView.firstOtherButtonIndex) {
            FirImAppInfoData* appInfo = objc_getAssociatedObject(alertView, "FirImAppInfoData");
            objc_removeAssociatedObjects(alertView);
            _checkUpdateDone = YES;
            [self.application openURL:[NSURL URLWithString:appInfo.update_url]];
        }

        _alertUpdateInfo = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    if (_hmServerId != NULL) {
        hm_server_disconnect(_hmServerId);
        _hmServerId = NULL;
        CSLog(@"hmServerId退出成功");
    }
    
    NSError *error;
    if (_managedObjectContext != nil) {
        //hasChanges方法是检查是否有未保存的上下文更改，如果有，则执行save方法保存上下文
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            CSLog(@"Error: %@,%@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    CSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", deviceToken);
    self.deviceToken = deviceToken;
    
    // 必须
    [BPush registerDeviceToken:deviceToken];
    
    if (![_preferences.deviceToken isEqualToData:deviceToken]) {
        _preferences.deviceToken = deviceToken;
    }
    
    // 一个 app 绑定成功至少一次即可(如果 access token 变更请重新绑定)。
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        CSLog(@"Method: %@\n%@", BPushRequestMethodBind, result);
        
        NSString *appid = [BPush getAppId];
        NSString *userid = [BPush getUserId];
        NSString *channelid = [BPush getChannelId];
        
        if (appid && userid && channelid) {
            CSLog(@"BPushErrorCode_Success");
            CSKuleBPushInfo* baiduPushInfo = [CSKuleBPushInfo new];
            baiduPushInfo.appId = appid;
            baiduPushInfo.userId = userid;
            baiduPushInfo.channelId = channelid;
            
            _preferences.baiduPushInfo = baiduPushInfo;
        }
        else {
            CSLog(@"BPushErrorCode_NOT_Success");
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    CSLog(@"%@", @"Did receive a Remote Notification");
    [self onRemotePushNotification:userInfo launching:NO];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self onLocalNotification:notification launching:NO];
}

#pragma mark - Remote/Local Notification
- (void)onRemotePushNotification:(NSDictionary*)userInfo launching:(BOOL)yes {
    if (yes) {
        CSLog(@"从推送消息启动:%@", userInfo);
        [BPush handleNotification:userInfo];
        [self.receivedNotifications addObject:userInfo];
        self.pendingNotificationInfo = userInfo;
    }
    else {
        CSLog(@"收到推送消息:%@", userInfo);

            if (self.application.applicationState == UIApplicationStateActive) {
                NSDictionary * rcData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
                if (rcData == nil) {
                    self.badgeOfCheckin = self.badgeOfCheckin + 1;
                    [self.application setApplicationIconBadgeNumber:0];
                }
            }
            else {
                if (userInfo) {
                    self.pendingNotificationInfo = userInfo;
                }
            }
            
            if (userInfo) {
                [self.receivedNotifications addObject:userInfo];
            }
            
            [BPush handleNotification:userInfo];
    
    }
}

- (void)onLocalNotification:(UILocalNotification*)notification launching:(BOOL)yes {
    if (yes) {
        CSLog(@"从本地消息启动:%@", notification);
    }
    else {
        CSLog(@"收到本地消息:%@", notification);
    }
}

#pragma mark - Getter & Setter
- (void)setLoginInfo:(CSKuleLoginInfo *)loginInfo {
    _loginInfo = loginInfo;
    CSLog(@"%s\n%@", __FUNCTION__, _loginInfo);
}

- (UIApplication*)application {
    return [UIApplication sharedApplication];
}

- (NSMutableArray*)receivedNotifications {
    if (_receivedNotifications == nil) {
        _receivedNotifications = [NSMutableArray array];
    }
    
    return _receivedNotifications;
}

#pragma mark - ShareSDK
- (void)setupShareSDK {
    [ShareSDK registerApp:@"77da60e4dcd8"];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wxf3c9e8b20267320e"
                           appSecret:@"b8058fb1aac2bac635332ea20679861b"
                           wechatCls:[WXApi class]];
}

#pragma mark - Setup
- (void)setupBaiduMobStat {
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = NO; // 是否允许截获并发送崩溃信息，请设置YES或者NO
#if COCOBABYS_DEV_MODEL
    statTracker.channelId = @"ios-dev";//设置您的app的发布渠道
#else
    statTracker.channelId = @"ios-appstore";//设置您的app的发布渠道
#endif
    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
    //statTracker.enableDebugOn = YES; //打开调试模式，发布时请去除此行代码或者设置为False即可。
    statTracker.logSendInterval = 1; //为1时表示发送日志的时间间隔为1小时,只有statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch这时才生效。
    statTracker.logSendWifiOnly = NO; //是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 15;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    [statTracker startWithAppId:@"ddbd3b0417"];//设置您在mtj网站上添加的app的appkey
}

- (void)setupEngine {
    
    //NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString* homeDir = NSHomeDirectory();
    NSString* cachesDirectory = [homeDir stringByAppendingPathComponent:@"Documents/File-Cache"];
    TSFileCache* fileCache = [TSFileCache cacheForURL:[NSURL fileURLWithPath:cachesDirectory isDirectory:YES]];
    [fileCache prepare:nil];
    [TSFileCache setSharedInstance:fileCache];
    
    if (_senderProfiles == nil) {
        _senderProfiles = [NSMutableDictionary dictionary];
    }
    else {
        [_senderProfiles removeAllObjects];
    }
    
    // 加载外观设置
    [self setupAppearance];
    
    // 加载默认配置
    [self setupPreferences];
    
    // 加载HttpClient
    [self setupHttpClient];
    
    // 加载HM_SDK
    [self setupHMSDK];
}

- (void)setupHMSDK {
    /* 初始化SDK */
    hm_result result = hm_sdk_init();
    if (result != HMEC_OK) {
        CSLog(@"hm_sdk_init failed - %d", result);
    }
}

- (void)setupPreferences {
    _preferences = [CSKulePreferences defaultPreferences];
    _loginInfo = _preferences.loginInfo;
}

- (void)setupHttpClient {
    self.httpClient = [CBHttpClient sharedInstance];
}

- (void)setCurrentRelationship:(CSKuleRelationshipInfo *)currentRelationship {
    _currentRelationship = currentRelationship;
    if (_currentRelationship) {
        _preferences.currentRelationshipUid = _currentRelationship.uid;
    }
    else {
        _preferences.currentRelationshipUid = 0;
    }
}

- (void)setupAppearance {
    UIImage* imgAlertBg = [UIImage imageNamed:@"alert-bg.png"];
    UIImage* imgBtnCancelBg = [[UIImage imageNamed:@"v2-btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    UIImage* imgBtnOkBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    imgAlertBg = [imgAlertBg resizableImageWithCapInsets:UIEdgeInsetsMake(100, 50, 10, 50)];
    
    id alertAppearance = [AHAlertView appearance];
    [alertAppearance setBackgroundImage:imgAlertBg];
    [alertAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [alertAppearance setMessageTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [alertAppearance setButtonBackgroundImage:imgBtnOkBg forState:UIControlStateNormal];
    [alertAppearance setCancelButtonBackgroundImage:imgBtnCancelBg forState:UIControlStateNormal];
    [alertAppearance setContentInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    //
    id naviAppearance = [UINavigationBar appearance];
    [naviAppearance setBackgroundImage:[UIImage imageNamed:@"v2-head.png"] forBarMetrics:UIBarMetricsDefault];
    [naviAppearance setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //naviAppearance.tintColor = [UIColor whiteColor];
    [naviAppearance setBarTintColor:[UIColor whiteColor]];
    [naviAppearance setTintColor:[UIColor whiteColor]];
    
    //
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
}

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path {
    return [self.httpClient urlFromPath:path];
}

//#pragma mark - BPushDelegate
//// 必须,如果正确调用了 setDelegate,在 bindChannel 之后,结果在这个回调中返回。若绑定失败,请进行重新绑定,确保至少绑定成功一次
//- (void)onMethod:(NSString*)method response:(NSDictionary*)data {
//    NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
//    if ([BPushRequestMethodBind isEqualToString:method]) {
//        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
//        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
//        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
//        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
//        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
//        
//        if (returnCode == 0) {
//            CSLog(@"BPushErrorCode_Success");
//            CSKuleBPushInfo* baiduPushInfo = [CSKuleBPushInfo new];
//            baiduPushInfo.appId = appid;
//            baiduPushInfo.userId = userid;
//            baiduPushInfo.channelId = channelid;
//            
//            _preferences.baiduPushInfo = baiduPushInfo;
//        }
//        else {
//            CSLog(@"BPushErrorCode_NOT_Success");
//        }
//    } else if ([BPushRequestMethodUnbind isEqualToString:method]) {
//        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
//        if (returnCode == 0) {
//            _preferences.baiduPushInfo = nil;
//        }
//    }
//}

#pragma mark - Core Data
-(NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //得到数据库的路径
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
    NSURL *storeUrl = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"Kulebao.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        CSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

-(NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator =[self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc]init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark - Retry
- (void)retryRequestOperationAfterBind:(AFHTTPRequestOperation*)operation {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        
        if (bindInfo.errorCode == 0) {
            _loginInfo.schoolId = bindInfo.schoolId;
            _loginInfo.accessToken = bindInfo.accessToken;
            _loginInfo.accountName = bindInfo.accountName;
            _loginInfo.username = bindInfo.username;
            _loginInfo.schoolName = bindInfo.schoolName;
            _loginInfo.memberStatus = bindInfo.memberStatus;
            _loginInfo.imToken = bindInfo.imToken;
            
            _preferences.loginInfo = _loginInfo;
            [gApp hideAlert];
            
#pragma warning - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx!!!!
            //[_httpClient enqueueHTTPRequestOperation:operation];
        }
        else {
            CSLog(@"[3]doReceiveBindInfo error_code=%ld", bindInfo.errorCode);
            [gApp gotoLoginProcess];
            [gApp alert:@"获取信息失败，请重新登录。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    if ([BPush getUserId] && [BPush getChannelId]) {
        [gApp waitingAlert:@"重新获取绑定信息..."];
        [gApp.engine.httpClient reqReceiveBindInfo:_loginInfo.accountName
                            success:sucessHandler
                            failure:failureHandler];
    }
    else {
        [gApp gotoLoginProcess];
        [gApp alert:@"获取信息失败，请重新登录。"];
    }
}

#pragma mark - Check Updates
- (void)checkUpdatesOfNews {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* newsInfos = [NSMutableArray array];
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        NSTimeInterval timestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleNews forChild:currentChild.childId];
        for (id newsInfoJson in dataJson) {
            CSKuleNewsInfo* newsInfo = [CSKuleInterpreter decodeNewsInfo:newsInfoJson];
            [newsInfos addObject:newsInfo];
            if (newsInfo.timestamp > timestamp) {
                timestamp = newsInfo.timestamp;
            }
        }
        
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleNews forChild:currentChild.childId];
        if (oldTimestamp < timestamp) {
            [gApp.engine.preferences setTimestamp:timestamp ofModule:kKuleModuleNews forChild:currentChild.childId];
            gApp.engine.badgeOfNews = 1;
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        //[gApp waitingAlert:@"正在获取数据"];
        [gApp.engine.httpClient reqGetNewsOfKindergarten:gApp.engine.loginInfo.schoolId
                                  withClassId:currentChild.classId
                                         from:-1
                                           to:-1
                                         most:1
                                      success:sucessHandler
                                      failure:failureHandler];
    }
    else {
        //[gApp alert:@"没有宝宝信息。"];
    }
}

- (void)checkUpdatesOfRecipe {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* cookbooks = [NSMutableArray array];
        
        for (id cookbookJson in dataJson) {
            CSKuleCookbookInfo* cookbookInfo = [CSKuleInterpreter decodeCookbookInfo:cookbookJson];
            [cookbooks addObject:cookbookInfo];
        }
        
        if (cookbooks.count > 0) {
            CSKuleCookbookInfo* cookbookInfo = [cookbooks firstObject];
            if (cookbookInfo.errorCode == 0) {
                
                CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
                NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleRecipe forChild:currentChild.childId];
                if (oldTimestamp < cookbookInfo.timestamp) {
                    gApp.engine.badgeOfRecipe = 1;
                    [gApp.engine.preferences setTimestamp:cookbookInfo.timestamp
                                                 ofModule:kKuleModuleRecipe
                                                 forChild:currentChild.childId];
                }
                
                //[gApp hideAlert];
            }
            else {
                //[gApp alert:@"获取数据失败"];
            }
        }
        else {
            //[gApp alert:@"没有食谱信息"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    //[gApp waitingAlert:@"正在获取数据"];
    [gApp.engine.httpClient reqGetCookbooksOfKindergarten:gApp.engine.loginInfo.schoolId
                                       success:sucessHandler
                                       failure:failureHandler];
}

- (void)checkUpdatesOfCheckin {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* checkInOutLogInfos = [NSMutableArray array];
        
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleCheckin forChild:currentChild.childId];
        NSTimeInterval timestamp = oldTimestamp;
        
        for (id checkInOutLogInfoJson in dataJson) {
            CSKuleCheckInOutLogInfo* checkInOutLogInfo = [CSKuleInterpreter decodeCheckInOutLogInfo:checkInOutLogInfoJson];
            [checkInOutLogInfos addObject:checkInOutLogInfo];
            if (timestamp < checkInOutLogInfo.timestamp) {
                timestamp = checkInOutLogInfo.timestamp;
            }
        }
        
        if (oldTimestamp < timestamp) {
            gApp.engine.badgeOfCheckin = 1;
            [gApp.engine.preferences setTimestamp:timestamp
                                         ofModule:kKuleModuleCheckin
                                         forChild:currentChild.childId];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        //[gApp waitingAlert:@"正在获取签到信息..."];
        [gApp.engine.httpClient reqGetCheckInOutLogOfChild:currentChild
                                 inKindergarten:gApp.engine.loginInfo.schoolId
                                           from:-1
                                             to:-1
                                           most:1
                                        success:sucessHandler
                                        failure:failureHandler];
    }
    else {
        //[gApp alert:@"没有宝宝信息。"];
    }
}

- (void)checkUpdatesOfSchedule {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* scheduleInfos = [NSMutableArray array];
        
        for (id scheduleInfoJson in dataJson) {
            CSKuleScheduleInfo* scheduleInfo = [CSKuleInterpreter decodeScheduleInfo:scheduleInfoJson];
            [scheduleInfos addObject:scheduleInfo];
        }
        
        CSKuleScheduleInfo* schduleInfo = [scheduleInfos firstObject];
        if (schduleInfo) {
            //[gApp hideAlert];
            
            CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
            NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleSchedule forChild:currentChild.childId];
            if (oldTimestamp < schduleInfo.timestamp) {
                gApp.engine.badgeOfSchedule = 1;
                [gApp.engine.preferences setTimestamp:schduleInfo.timestamp ofModule:kKuleModuleSchedule forChild:currentChild.childId];
            }
        }
        else {
            //[gApp alert:@"没有课程表信息"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        //[gApp waitingAlert:@"获取信息中..."];
        [gApp.engine.httpClient reqGetSchedulesOfKindergarten:gApp.engine.loginInfo.schoolId
                                       withClassId:currentChild.classId
                                           success:sucessHandler
                                           failure:failureHandler];
    }
    else {
        //[gApp alert:@"没有宝宝信息。"];
    }
}

- (void)checkUpdatesOfAssignment {
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* assignmentInfos = [NSMutableArray array];
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleAssignment forChild:currentChild.childId];
        NSTimeInterval timestamp = oldTimestamp;
        
        for (id assignmentInfoJson in dataJson) {
            CSKuleAssignmentInfo* assignmentInfo = [CSKuleInterpreter decodeAssignmentInfo:assignmentInfoJson];
            [assignmentInfos addObject:assignmentInfo];
            if (timestamp < assignmentInfo.timestamp) {
                timestamp = assignmentInfo.timestamp;
            }
        }
        
        if (oldTimestamp < timestamp) {
            gApp.engine.badgeOfAssignment = 1;
            [gApp.engine.preferences setTimestamp:timestamp
                                         ofModule:kKuleModuleAssignment
                                         forChild:currentChild.childId];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    [gApp.engine.httpClient reqGetAssignmentsOfKindergarten:gApp.engine.loginInfo.schoolId
                                     withClassId:currentChild.classId
                                            from:-1
                                              to:-1
                                            most:1
                                         success:sucessHandler
                                         failure:failureHandler];
}

- (void)checkUpdatesOfChating {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* chatMsgs = [NSMutableArray array];
        
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleChating forChild:currentChild.childId];
        NSTimeInterval timestamp = oldTimestamp;
        
        if ([dataJson isKindOfClass:[NSArray class]]) {
            for (id chatMsgJson in dataJson) {
                CSKuleTopicMsg* chatMsg = [CSKuleInterpreter decodeTopicMsg:chatMsgJson];
                [chatMsgs addObject:chatMsg];
                
                if (timestamp < chatMsg.timestamp) {
                    timestamp = chatMsg.timestamp;
                }
            }
        }
        else if ([dataJson isKindOfClass:[NSDictionary class]]) {
            CSKuleTopicMsg* chatMsg = [CSKuleInterpreter decodeTopicMsg:dataJson];
            [chatMsgs addObject:chatMsg];
            if (timestamp < chatMsg.timestamp) {
                timestamp = chatMsg.timestamp;
            }
        }
        
        if (oldTimestamp < timestamp) {
            gApp.engine.badgeOfChating = 1;
            [gApp.engine.preferences setTimestamp:timestamp
                                         ofModule:kKuleModuleChating
                                         forChild:currentChild.childId];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    //[gApp waitingAlert:@"获取信息中..."];
    [gApp.engine.httpClient reqGetTopicMsgsOfKindergarten:gApp.engine.loginInfo.schoolId
                                          from:-1
                                            to:-1
                                          most:1
                                       success:sucessHandler
                                       failure:failureHandler];
}

- (void)checkUpdatesOfAssess {
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* assessInfos = [NSMutableArray array];
        
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleAssess forChild:currentChild.childId];
        NSTimeInterval timestamp = oldTimestamp;
        
        for (id assessInfoJson in dataJson) {
            CSKuleAssessInfo* assessInfo = [CSKuleInterpreter decodeAssessInfo:assessInfoJson];
            [assessInfos addObject:assessInfo];
            
            if (timestamp < assessInfo.timestamp) {
                timestamp = assessInfo.timestamp;
            }
        }
        
        if (oldTimestamp < timestamp) {
            gApp.engine.badgeOfAssess = 1;
            [gApp.engine.preferences setTimestamp:timestamp
                                         ofModule:kKuleModuleAssess
                                         forChild:currentChild.childId];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:[error localizedDescription]];
    };
    
    //[gApp waitingAlert:@"获取评价中"];
    [gApp.engine.httpClient reqGetAssessesOfChild:currentChild
                        inKindergarten:gApp.engine.loginInfo.schoolId
                                  from:-1
                                    to:-1
                                  most:1
                               success:sucessHandler
                               failure:failureHandler];
}

@end

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

#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"

@interface CSKuleEngine() {
    NSMutableDictionary* _senderProfiles;
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) CSHttpClient* httpClient;
@property (strong, nonatomic) CSHttpClient* qiniuHttpClient;

//数据模型对象
@property(strong,nonatomic) NSManagedObjectModel* managedObjectModel;
//上下文对象
@property(strong,nonatomic) NSManagedObjectContext* managedObjectContext;
//持久性存储区
@property(strong,nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation CSKuleEngine
@synthesize httpClient = _httpClient;
@synthesize qiniuHttpClient = _qiniuHttpClient;
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
        CSLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
        
        [self.receivedNotifications addObject:userInfo];
    }
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

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
            [self checkUpdatesOfChating];
            [self checkUpdatesOfAssess];
        }
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
    //NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
        //                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@", alert]
        //                                                           delegate:self
        //                                                  cancelButtonTitle:@"OK"
        //                                                  otherButtonTitles:nil];
        //        [alertView show];
        
        self.badgeOfCheckin = self.badgeOfCheckin + 1;
        [application setApplicationIconBadgeNumber:0];
    }
    
    [BPush handleNotification:userInfo];
    [self.receivedNotifications addObject:userInfo];
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
    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.channelId = @"ios-dev";//设置您的app的发布渠道
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
    NSString* homeDir = NSHomeDirectory();
    NSString* cachePath = [homeDir stringByAppendingPathComponent:@"Documents/Kule-Cache"];
    
    CSKuleURLCache* cache = [[CSKuleURLCache alloc] initWithMemoryCapacity:1024
                                                              diskCapacity:512*1024*1024
                                                                  diskPath:cachePath];
    [CSKuleURLCache setSharedURLCache:cache];
    
    if (_httpClient == nil) {
//        NSURL* baseUrl = [NSURL URLWithString:kServerHostForProd];
//        if (_preferences.enabledTest) {
//            baseUrl = [NSURL URLWithString:kServerHostForTest];
//        }
        NSDictionary* serverInfo = [_preferences getServerSettings];
        NSString* serverUrlString = serverInfo[@"url"];
        if(serverUrlString.length == 0) {
            serverUrlString = kServerHostForProd;
        }
        _httpClient = [CSHttpClient httpClientWithHost:[NSURL URLWithString:serverUrlString]];
    }
    
    if (_qiniuHttpClient == nil) {
        NSURL* baseUrl = [NSURL URLWithString:kQiniuUploadServerHost];
        _qiniuHttpClient = [CSHttpClient httpClientWithHost:baseUrl];
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
}

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path {
    NSURL* url = nil;
    if (path.length > 0) {
        if ([path hasPrefix:@"http"]
            || [path hasPrefix:@"https"]) {
            url = [NSURL URLWithString:path];
        }
        else {
            url = [NSURL URLWithString:path
                         relativeToURL:_httpClient.baseURL];
        }
    }
    
    return url;
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

#pragma mark - Uploader
- (void)reqUploadToQiniu:(NSData*)data
                 withKey:(NSString*)key
                withMime:(NSString*)mime
                 success:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure {
    NSParameterAssert(data);
    NSParameterAssert(key);
    NSParameterAssert(mime);
    
    [self reqGetUploadTokenWithKey:key success:^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* token = [dataJson valueForKeyNotNull:@"token"];
        
        if (token) {
            [self reqUploadQiniuWithData:data
                               withToken:token
                                  andKey:key
                                 andMime:mime
                                 success:success
                                 failure:failure];
        }
        else {
            NSError* error = [NSError errorWithDomain:@"CSKit"
                                                 code:-8888
                                             userInfo: @{NSLocalizedDescriptionKey:@"Invalid Token."}];
            
            failure(operation, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

- (void)reqGetUploadTokenWithKey:(NSString*)key
                         success:(SuccessResponseHandler)success
                         failure:(FailureResponseHandler)failure {
    NSParameterAssert(key);
    
    NSString* path = kUploadFileTokenPath;
    
    NSString* method = @"GET";
    
    NSDictionary* parameters = @{@"bucket": kQiniuBucket,
                                 @"key": key};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqUploadQiniuWithData:(NSData*)data
                     withToken:(NSString*)token
                        andKey:(NSString*)key
                       andMime:(NSString*)mime
                       success:(SuccessResponseHandler)success
                       failure:(FailureResponseHandler)failure {
    
    NSMutableURLRequest* req = [_qiniuHttpClient multipartFormRequestWithMethod:@"POST" path:@"/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:mime];
        [formData appendPartWithFormData:[key dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
        [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    }];
    
    AFJSONRequestOperation* oper = [AFJSONRequestOperation CSJSONRequestOperationWithRequest:req
                                                                                     success:success
                                                                                     failure:failure];
    [_qiniuHttpClient enqueueHTTPRequestOperation:oper];
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
            
            _preferences.loginInfo = _loginInfo;
            [gApp hideAlert];
            
            [_httpClient enqueueHTTPRequestOperation:operation];
        }
        else {
            CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
            [gApp gotoLoginProcess];
            [gApp alert:@"获取信息失败，请重新登录。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    if ([BPush getUserId] && [BPush getChannelId]) {
        [gApp waitingAlert:@"重新获取绑定信息..."];
        [gApp.engine reqReceiveBindInfo:_loginInfo.accountName
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
        [gApp.engine reqGetNewsOfKindergarten:gApp.engine.loginInfo.schoolId
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
    [gApp.engine reqGetCookbooksOfKindergarten:gApp.engine.loginInfo.schoolId
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
        [gApp.engine reqGetCheckInOutLogOfChild:currentChild
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
        [gApp.engine reqGetSchedulesOfKindergarten:gApp.engine.loginInfo.schoolId
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
    
    [gApp.engine reqGetAssignmentsOfKindergarten:gApp.engine.loginInfo.schoolId
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
    [gApp.engine reqGetTopicMsgsOfKindergarten:gApp.engine.loginInfo.schoolId
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
    [gApp.engine reqGetAssessesOfChild:currentChild
                        inKindergarten:gApp.engine.loginInfo.schoolId
                                  from:-1
                                    to:-1
                                  most:1
                               success:sucessHandler
                               failure:failureHandler];
}

#pragma mark - HTTP Request
- (void)reqCheckPhoneNum:(NSString*)mobile
                 success:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure {
    NSString* path = kCheckPhoneNumPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"phonenum":mobile};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqLogin:(NSString*)mobile
        withPswd:(NSString*)password
         success:(SuccessResponseHandler)success
         failure:(FailureResponseHandler)failure {
    NSParameterAssert(mobile);
    NSParameterAssert(password);
    
    NSString* path = kLoginPath;

    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"account_name":mobile,
                                 @"password":password};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqReceiveBindInfo:(NSString*)mobile
                   success:(SuccessResponseHandler)success
                   failure:(FailureResponseHandler)failure {
    NSParameterAssert(mobile);
    
    NSString* path = kReceiveBindInfoPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = nil;
    
    if ([BPush getChannelId] && [BPush getUserId]) {
        parameters = @{@"phonenum": mobile,
                       @"user_id": [BPush getUserId],
                       @"channel_id": [BPush getChannelId],
                       @"access_token": _loginInfo.accessToken ? _loginInfo.accessToken : @"",
                       @"device_type": @"ios"};
    }
    else {
        CSLog(@"");
        parameters = @{@"phonenum": mobile,
                       @"user_id": @"",
                       @"channel_id": @"",
                       @"access_token":_loginInfo.accessToken ? _loginInfo.accessToken : @"",
                       @"device_type": @"ios"};
    }
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqUnbindWithSuccess:(SuccessResponseHandler)success
                     failure:(FailureResponseHandler)failure {
    NSString* path = kReceiveBindInfoPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = nil;
    
    parameters = @{@"phonenum": _loginInfo.accountName,
                   @"user_id": @"",
                   @"channel_id": @"",
                   @"access_token": _loginInfo.accessToken ? _loginInfo.accessToken : @"",
                   @"device_type": @"ios"};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (void)reqChangePassword:(NSString*)newPswd
              withOldPswd:(NSString*)oldPswd
                  success:(SuccessResponseHandler)success
                  failure:(FailureResponseHandler)failure {
    NSParameterAssert(newPswd);
    NSParameterAssert(oldPswd);
    
    NSString* path = kChangePasswordPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"account_name": _loginInfo.accountName,
                                 @"old_password": oldPswd,
                                 @"new_password": newPswd};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetFamilyRelationship:(NSString*)mobile
                  inKindergarten:(NSInteger)kindergarten
                         success:(SuccessResponseHandler)success
                         failure:(FailureResponseHandler)failure {
    NSParameterAssert(mobile);
    
    NSString* path = [NSString stringWithFormat:kGetFamilyRelationshipPath, @(kindergarten)];

    NSString* method = @"GET";

    NSDictionary* parameters = @{@"parent": mobile};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqUpdateChildInfo:(CSKuleChildInfo*)childInfo
            inKindergarten:(NSInteger)kindergarten
                   success:(SuccessResponseHandler)success
                   failure:(FailureResponseHandler)failure {
    NSParameterAssert(childInfo);
    
    NSString* path = [NSString stringWithFormat:kChildInfoPath, @(kindergarten), childInfo.childId];
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"name": childInfo.name,
                                 @"nick": childInfo.nick,
                                 @"birthday": childInfo.birthday,
                                 @"gender": @(childInfo.gender),
                                 @"portrait": childInfo.portrait,
                                 @"class_id": @(childInfo.classId),
                                 @"child_id": childInfo.childId,
                                 @"class_name": childInfo.className,};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetNewsOfKindergarten:(NSInteger)kindergarten
                     withClassId:(NSInteger)classId
                            from:(NSInteger)fromId
                              to:(NSInteger)toId
                            most:(NSInteger)most
                         success:(SuccessResponseHandler)success
                         failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kKindergartenNewsListPathV2, @(kindergarten)];
    
    NSString* method = @"GET";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    if (classId > 0) {
        [parameters setObject:@(classId) forKey:@"class_id"];
    }
    
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    [parameters setObject:@(1) forKey:@"tag"];
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetCookbooksOfKindergarten:(NSInteger)kindergarten
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kKindergartenCookbooksPath, @(kindergarten)];
    
    NSString* method = @"GET";
    
    NSDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetAssignmentsOfKindergarten:(NSInteger)kindergarten
                            withClassId:(NSInteger)classId
                                   from:(NSInteger)fromId
                                     to:(NSInteger)toId
                                   most:(NSInteger)most
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kAssignmentListPath, @(kindergarten)];
    
    NSString* method = @"GET";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (classId > 0) {
        [parameters setObject:@(classId) forKey:@"class_id"];
    }
    
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetSchedulesOfKindergarten:(NSInteger)kindergarten
                          withClassId:(NSInteger)classId
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kSchedulesPath, @(kindergarten), @(classId)];
    
    NSString* method = @"GET";
    
    NSDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (void)reqGetSchoolInfoOfKindergarten:(NSInteger)kindergarten
                               success:(SuccessResponseHandler)success
                               failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kGetSchoolInfoPath, @(kindergarten)];
    
    NSString* method = @"GET";
    
    NSDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (void)reqGetCheckInOutLogOfChild:(CSKuleChildInfo*)childInfo
                    inKindergarten:(NSInteger)kindergarten
                              from:(NSTimeInterval)fromTimestamp
                                to:(NSTimeInterval)toTimestamp
                              most:(NSInteger)most
                           success:(SuccessResponseHandler)success
                           failure:(FailureResponseHandler)failure {
    NSParameterAssert(childInfo);
    
    NSString* path = [NSString stringWithFormat:kGetCheckInOutLogPath, @(kindergarten), childInfo.childId];
    
    NSString* method = @"GET";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    if (fromTimestamp >= 0) {
        [parameters setObject:@((long long)(fromTimestamp*1000)) forKey:@"from"];
    }
    
    if (toTimestamp >= 0) {
        [parameters setObject:@((long long)(toTimestamp*1000)) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

//- (void)reqGetChatingMsgsOfKindergarten:(NSInteger)kindergarten
//                                   from:(long long)fromId
//                                     to:(long long)toId
//                                   most:(NSInteger)most
//                                success:(SuccessResponseHandler)success
//                                failure:(FailureResponseHandler)failure {
//    NSParameterAssert(_loginInfo.accountName);
//    
//    NSString* path = [NSString stringWithFormat:kChatingPath, @(kindergarten), _loginInfo.accountName];
//    
//    NSString* method = @"GET";
//    
//    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
//    if (fromId >= 0) {
//        [parameters setObject:@(fromId) forKey:@"from"];
//    }
//    
//    if (toId >= 0) {
//        [parameters setObject:@(toId) forKey:@"to"];
//    }
//    
//    if (most >= 0) {
//        [parameters setObject:@(most) forKey:@"most"];
//    }
//    
//    [_httpClient httpRequestWithMethod:method
//                                  path:path
//                            parameters:parameters
//                               success:success
//                               failure:failure];
//}

- (void)reqSendChatingMsg:(NSString*)msgBody
                withImage:(NSString*)imgUrl
           toKindergarten:(NSInteger)kindergarten
             retrieveFrom:(long long)fromId
                  success:(SuccessResponseHandler)success
                  failure:(FailureResponseHandler)failure {
    NSParameterAssert(msgBody || imgUrl); // 不能同时为空
    NSParameterAssert(_loginInfo.accountName);
    
    NSString* path = [NSString stringWithFormat:kChatingPath, @(kindergarten), _loginInfo.accountName];
    
    if (fromId >= 0) {
        path = [path stringByAppendingFormat:@"?retrieve_recent_from=%lld", fromId];
    }
    
    NSString* method = @"POST";
    
    /*
     {"phone":"123456789","timestamp":1392967799188,"content":"谢谢你的鼓励","image":"http://suoqin-test.u.qiniudn.com/Fget0Tx492DJofAy-ZeUg1SANJ4X","sender":"带班老师"}
     */
    
    long long timestamp = [[NSDate date] timeIntervalSince1970]*1000;
    
    NSString* msgImage = @"";
    if (imgUrl.length > 0) {
        msgImage = [[self urlFromPath:imgUrl] absoluteString];
    }
    
    NSDictionary* parameters = @{@"phone": _loginInfo.accountName,
                                 @"timestamp": @(timestamp),
                                 @"content": msgBody ? msgBody : @"",
                                 @"image": msgImage,
                                 @"sender": @""};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                 from:(long long)fromId
                                   to:(long long)toId
                                 most:(NSInteger)most
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure {
    if (_currentRelationship == nil) {
        return;
    }
    
    NSParameterAssert(_currentRelationship.child);
    
    NSString* path = [NSString stringWithFormat:kTopicPath, @(kindergarten), _currentRelationship.child.childId];
    
    NSString* method = @"GET";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqDeleteTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                recordId:(long long)msgId
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(_currentRelationship.child);
    
    NSString* path = [NSString stringWithFormat:kTopicIdPath, @(kindergarten), _currentRelationship.child.childId, @(msgId)];
    NSString* method = @"DELETE";
    
    NSMutableDictionary* parameters = nil;
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqSendTopicMsg:(NSString*)msgBody
           withMediaUrl:(NSString*)mediaUrl
            ofMediaType:(NSString*)mediaType
         toKindergarten:(NSInteger)kindergarten
           retrieveFrom:(long long)fromId
                success:(SuccessResponseHandler)success
                failure:(FailureResponseHandler)failure {
    NSParameterAssert(msgBody || mediaUrl); // 不能同时为空
    NSParameterAssert(_currentRelationship.child);
    
    
    NSString* path = [NSString stringWithFormat:kTopicPath, @(kindergarten), _currentRelationship.child.childId];
    
    if (fromId >= 0) {
        path = [path stringByAppendingFormat:@"?retrieve_recent_from=%lld", fromId];
    }
    
    NSString* method = @"POST";
    
    /*
     {"topic":"1_1396844597394",
     "content":"我再说两句",
     "media":{"url":"http://suoqin-test.u.qiniudn.com/FgPmIcRG6BGocpV1B9QMCaaBQ9LK","type":"image"},
     "sender":{"id":"2_1003_1396844438388","type":"p"}}
     */
    
    long long timestamp = [[NSDate date] timeIntervalSince1970]*1000;
    
    id msgMedia = @{@"url": @"",
                    @"type": @""};
    
    if (mediaUrl.length > 0) {
        msgMedia = @{@"url": SAFE_STRING([[self urlFromPath:mediaUrl] absoluteString]),
                     @"type": mediaType};
    }
    
    id msgSender = @{@"id": _currentRelationship.parent.parentId,
                     @"type": @"p"};
    
    NSDictionary* parameters = @{@"topic": _currentRelationship.child.childId,
                                 @"timestamp": @(timestamp),
                                 @"content": msgBody ? msgBody : @"",
                                 @"media": msgMedia,
                                 @"sender": msgSender};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetAssessesOfChild:(CSKuleChildInfo*)childInfo
               inKindergarten:(NSInteger)kindergarten
                         from:(NSInteger)fromId
                           to:(NSInteger)toId
                         most:(NSInteger)most
                      success:(SuccessResponseHandler)success
                      failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(childInfo);
    
    NSString* path = [NSString stringWithFormat:kAssessPath, @(kindergarten), childInfo.childId];
    
    NSString* method = @"GET";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetSmsCode:(NSString*)phone
              success:(SuccessResponseHandler)success
              failure:(FailureResponseHandler)failure {
    NSParameterAssert(phone);

    NSString* path = [NSString stringWithFormat:kGetSmsCodePath, phone];
    
    NSString* method = @"GET";
    
    NSDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqBindPhone:(NSString*)phone
             smsCode:(NSString*)authcode
             success:(SuccessResponseHandler)success
             failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetSmsCodePath, phone];
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"phone": phone,
                                 @"code": authcode};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqResetPswd:(NSString*)account
             smsCode:(NSString*)authcode
         withNewPswd:(NSString*)newPswd
             success:(SuccessResponseHandler)success
             failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(account);
    NSParameterAssert(authcode);
    NSParameterAssert(newPswd);
    
    NSString* path = kResetPswdPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"account_name": account,
                                 @"authcode": authcode,
                                 @"new_password": newPswd};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (void)reqSendFeedback:(NSString*)account
            withContent:(NSString*)msgContent
                success:(SuccessResponseHandler)success
                failure:(FailureResponseHandler)failure {
    NSParameterAssert(account);
    NSParameterAssert(msgContent);
    
    NSString* path = kFeedbackPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = @{@"phone": account,
                                 @"content": msgContent,
                                 @"source": @"ios_parent"};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetEmployeeListOfKindergarten:(NSInteger)kindergarten
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetEmployeeInfoPath, @(kindergarten)];
    
    NSString* method = @"GET";
    
    NSDictionary* parameters = @{};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (void)reqGetSenderProfileOfKindergarten:(NSInteger)kindergarten
                               withSender:(CSKuleSenderInfo*)senderInfo
                                 complete:(void (^)(id obj))complete {
    if (senderInfo.senderId.length > 0) {
        id obj = [_senderProfiles objectForKey:senderInfo.senderId];
        if (obj && complete) {
            complete(obj);
        }
        else if(obj == nil) {
            if ([senderInfo.type isEqualToString:@"t"] || [senderInfo.type isEqualToString:@"p"]) {
                NSString* path = [NSString stringWithFormat:kGetSenderInfoPath, @(kindergarten), senderInfo.senderId];
                
                NSString* method = @"GET";
                
                NSDictionary* parameters = @{@"type": senderInfo.type};
                
                id success = ^(AFHTTPRequestOperation *operation, id dataJson) {
                    id profile = nil;
                    if ([senderInfo.type isEqualToString:@"t"]) {
                        profile = [CSKuleInterpreter decodeEmployeeInfo:dataJson];
                    }
                    else if ([senderInfo.type isEqualToString:@"p"]) {
                        profile = [CSKuleInterpreter decodeParentInfo:dataJson];
                    }
                    
                    if (profile) {
                        [_senderProfiles setObject:profile forKey:senderInfo.senderId];
                    }
                    
                    if (complete) {
                        complete(profile);
                    }
                };
                
                id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                };
                
                [_httpClient httpRequestWithMethod:method
                                              path:path
                                        parameters:parameters
                                           success:success
                                           failure:failure];
            }
        }
    }
}


- (void)reqGetHistoryListOfKindergarten:(NSInteger)kindergarten
                            withChildId:(NSString*)childId
                               fromDate:(NSDate*)fromDate
                                 toDate:(NSDate*)toDate
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetHistoryListPath, @(kindergarten), childId];
    
    NSString* method = @"GET";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (fromDate) {
        long long msec = [fromDate timeIntervalSince1970] * 1000;
        [parameters setObject:@(msec) forKey:@"from"];
    }
    
    if (toDate) {
        long long msec = [toDate timeIntervalSince1970] * 1000;
        [parameters setObject:@(msec) forKey:@"to"];
    }
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqPostHistoryOfKindergarten:(NSInteger)kindergarten
                         withChildId:(NSString*)childId
                         withContent:(NSString*)content
                    withImageUrlList:(NSArray*)imgUrlList
                        withVideoUrl:(NSString*)videoUrl
                             success:(SuccessResponseHandler)success
                             failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetHistoryListPath, @(kindergarten), childId];

    NSString* method = @"POST";
    
    id msgSender = @{@"id": _currentRelationship.parent.parentId,
                     @"type": @"p"};
    
    NSMutableArray* mediumList = [NSMutableArray array];
    for (NSString* urlString in imgUrlList) {
        [mediumList addObject:@{@"url": urlString, @"type": @"image"}];
    }
    
    if (videoUrl.length > 0) {
        [mediumList addObject:@{@"url": videoUrl, @"type": @"video"}];
    }
    
    NSDictionary* parameters = @{@"topic": childId,
                                 @"content": content ? content : @"",
                                 @"medium" : mediumList,
                                 @"sender": msgSender};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqDeleteHistoryOfKindergarten:(NSInteger)kindergarten
                           withChildId:(NSString*)childId
                              recordId:(long long)msgId
                               success:(SuccessResponseHandler)success
                               failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kDeleteHistoryListPath, @(kindergarten), childId, @(msgId)];
    NSString* method = @"DELETE";
    NSMutableDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetVideoMemberListOfKindergarten:(NSInteger)kindergarten
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kGetVideoMemberListPath, @(kindergarten)];
    NSString* method = @"GET";
    NSMutableDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (void)reqGetVideoMemberOfKindergarten:(NSInteger)kindergarten
                           withParentId:(NSString*)parentId
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetVideoMemberPath, @(kindergarten), parentId];
    NSString* method = @"GET";
    NSMutableDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (void)reqGetDefaultVideoMemberOfKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetDefaultVideoMemberPath, @(kindergarten)];
    NSString* method = @"GET";
    NSMutableDictionary* parameters = nil;
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}

- (AFHTTPRequestOperation*)reqMarkAsRead:(CSKuleNewsInfo*)newsInfo
                                byParent:(CSKuleParentInfo*)parentInfo
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    NSParameterAssert(newsInfo);
    NSParameterAssert(parentInfo);
    
    NSString* path = [NSString stringWithFormat:kKindergartenNewsMarkedPathV2, @(parentInfo.schoolId),
                      @(newsInfo.newsId)];
    NSString* method = @"POST";
    NSDictionary* parameters = @{
                                 @"school_id": @(parentInfo.schoolId),
                                 @"name": parentInfo.name,
                                 @"phone": parentInfo.phone,
                                 @"portrait": parentInfo.portrait,
                                 @"gender": @(parentInfo.gender),
                                 @"birthday": parentInfo.birthday,
                                 @"parent_id": parentInfo.parentId,
                                 @"timestamp": @(parentInfo.timestamp),
                                 @"member_status": @(parentInfo.memberStatus),
                                 @"status": @(parentInfo.status)};
    
    return [_httpClient httpRequestWithMethod:method
                                         path:path
                                   parameters:parameters
                                      success:success
                                      failure:failure];
}

- (AFHTTPRequestOperation*)reqQueryReadStatusOf:(CSKuleNewsInfo*)newsInfo
                                       byParent:(CSKuleParentInfo*)parentInfo
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure {
    NSParameterAssert(newsInfo);
    NSParameterAssert(parentInfo);
    
    NSString* path = [NSString stringWithFormat:kKindergartenNewsMarkedStatusPathV2,
                      @(parentInfo.schoolId),
                      @(newsInfo.newsId),
                      parentInfo.parentId];
    
    NSString* method = @"GET";
    NSDictionary* parameters = nil;
    
    return [_httpClient httpRequestWithMethod:method
                                         path:path
                                   parameters:parameters
                                      success:success
                                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetBusLocationOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kBusLocationPathV2, @(kindergarten), childId];
    NSString* method = @"GET";
    NSMutableDictionary* parameters = nil;
    
    return [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

- (AFHTTPRequestOperation*)reqGetShareTokenOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                             withRecordId:(NSInteger)recordId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetShareTokenV3, @(kindergarten), childId, @(recordId)];
    NSString* method = @"POST";
    NSMutableDictionary* parameters = nil;
    
    return [_httpClient httpRequestWithMethod:method
                                         path:path
                                   parameters:parameters
                                      success:success
                                      failure:failure];
}

@end

//
//  CSKuleEngine.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleEngine.h"
#import "CSAppDelegate.h"
#import "BPush.h"
#import "AHAlertView.h"

@interface CSKuleEngine() <BPushDelegate>

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
@synthesize baiduPushInfo = _baiduPushInfo;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // 添加Baidu Push
    [BPush setupChannel:launchOptions];
    // 必须。参数对象必须实现(void)onMethod:(NSString*)method response:(NSDictionary*)data 方法, 本示例中为 self
    [BPush setDelegate:self];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert
     | UIRemoteNotificationTypeBadge
     | UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
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
    // 必须
    [BPush registerDeviceToken:deviceToken];
    
    if (![_preferences.deviceToken isEqualToData:deviceToken]) {
        _preferences.deviceToken = deviceToken;
        _preferences.baiduPushInfo = nil;
        _baiduPushInfo = nil;
    
        // 必须。可以在其它时机调用,只有在该方法返回(通过 onMethod:response:回调)绑定成功时,app 才能接收到 Push 消息。
        // 一个 app 绑定成功至少一次即可(如果 access token 变更请重新绑定)。
        [BPush bindChannel];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
        //                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@", alert]
        //                                                           delegate:self
        //                                                  cancelButtonTitle:@"OK"
        //                                                  otherButtonTitles:nil];
        //        [alertView show];
        
        CSLog(@"%@", @"Did receive a Remote Notification");
    }
    
    [application setApplicationIconBadgeNumber:0];
    [BPush handleNotification:userInfo];
}

#pragma mark - Getter & Setter
- (void)setLoginInfo:(CSKuleLoginInfo *)loginInfo {
    _loginInfo = loginInfo;
    CSLog(@"%s\n%@", __FUNCTION__, _loginInfo);
}

- (void)setBaiduPushInfo:(CSKuleBPushInfo *)baiduPushInfo {
    _baiduPushInfo = baiduPushInfo;
     CSLog(@"%s\n%@", __FUNCTION__, _baiduPushInfo);
}

#pragma mark - Setup
- (void)setupEngine {
    // 加载外观设置
    [self setupAppearance];
    
    // 加载默认配置
    [self setupPreferences];
    
    // 加载HttpClient
    [self setupHttpClient];
}

- (void)setupPreferences {
    _preferences = [CSKulePreferences defaultPreferences];
    _loginInfo = _preferences.loginInfo;
    _baiduPushInfo = _preferences.baiduPushInfo;
}

- (void)setupHttpClient {
    if (_httpClient == nil) {
        NSURL* baseUrl = [NSURL URLWithString:kServerHost];
        _httpClient = [CSHttpClient httpClientWithHost:baseUrl];
    }
    
    if (_qiniuHttpClient == nil) {
        NSURL* baseUrl = [NSURL URLWithString:kQiniuUploadServerHost];
        _qiniuHttpClient = [CSHttpClient httpClientWithHost:baseUrl];
    }
}

- (void)setupAppearance {
    UIImage* imgAlertBg = [UIImage imageNamed:@"alert-bg.png"];
    UIImage* imgBtnBg = [UIImage imageNamed:@"btn-type1.png"];
    UIImage* imgBtnPressedBg = [UIImage imageNamed:@"btn-type1-pressed.png"];
    
    imgAlertBg = [imgAlertBg resizableImageWithCapInsets:UIEdgeInsetsMake(100, 50, 10, 50)];
    
    id alertAppearance = [AHAlertView appearance];
    [alertAppearance setBackgroundImage:imgAlertBg];
    [alertAppearance setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor],}];
    [alertAppearance setMessageTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor],}];
    [alertAppearance setButtonBackgroundImage:imgBtnBg forState:UIControlStateNormal];
    [alertAppearance setCancelButtonBackgroundImage:imgBtnBg forState:UIControlStateNormal];
    [alertAppearance setButtonBackgroundImage:imgBtnPressedBg forState:UIControlStateHighlighted];
    [alertAppearance setCancelButtonBackgroundImage:imgBtnPressedBg forState:UIControlStateHighlighted];
    [alertAppearance setContentInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
}

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path {
    NSURL* url = nil;
    if (path.length > 0) {
        if ([path hasPrefix:@"http"]) {
            url = [NSURL URLWithString:path];
        }
        else {
            url = [NSURL URLWithString:path
                         relativeToURL:[NSURL URLWithString:kServerHost]];
        }
    }
    
    return url;
}

#pragma mark - BPushDelegate
// 必须,如果正确调用了 setDelegate,在 bindChannel 之后,结果在这个回调中返回。若绑定失败,请进行重新绑定,确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        
        if (returnCode == BPushErrorCode_Success) {
            CSLog(@"BPushErrorCode_Success");
            CSKuleBPushInfo* baiduPushInfo = [CSKuleBPushInfo new];
            baiduPushInfo.appId = appid;
            baiduPushInfo.userId = userid;
            baiduPushInfo.channelId = channelid;
            
            self.baiduPushInfo = baiduPushInfo;
            _preferences.baiduPushInfo = baiduPushInfo;
        }
        else {
            //self.baiduPushInfo = nil;
            //_preferences.baiduPushInfo = nil;
        }
    } else if ([BPushRequestMethod_Unbind isEqualToString:method]) {
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode == BPushErrorCode_Success) {
            self.baiduPushInfo = nil;
            _preferences.baiduPushInfo = nil;
        }
    }
}

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
    
    [self reqGetUploadTokenWithKey:key success:^(NSURLRequest *request, id dataJson) {
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
            
            failure(request, error);
        }
        
    } failure:^(NSURLRequest *request, NSError *error) {
        failure(request, error);
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
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        
        if (bindInfo.errorCode == 0) {
            gApp.engine.loginInfo.schoolId = bindInfo.schoolId;
            gApp.engine.loginInfo.accessToken = bindInfo.accessToken;
            gApp.engine.loginInfo.accountName = bindInfo.accountName;
            gApp.engine.loginInfo.username = bindInfo.username;
            gApp.engine.loginInfo.schoolName = bindInfo.schoolName;
            
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            [gApp hideAlert];
            
            [_httpClient enqueueHTTPRequestOperation:operation];
        }
        else {
            CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
            [gApp gotoLoginProcess];
            [gApp alert:@"获取信息失败，请重新登录。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    [gApp waitingAlert:@"重新获取绑定信息..."];
    [gApp.engine reqReceiveBindInfo:gApp.engine.loginInfo.accountName
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
                       @"access_token": gApp.engine.loginInfo.accessToken ? gApp.engine.loginInfo.accessToken : @"",
                       @"device_type": @"ios"};
    }
    else {
        CSLog(@"");
        parameters = @{@"phonenum": mobile,
                       @"user_id": @"",
                       @"channel_id": @"",
                       @"access_token": gApp.engine.loginInfo.accessToken ? gApp.engine.loginInfo.accessToken : @"",
                       @"device_type": @"ios"};
    }
    
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
    NSString* path = [NSString stringWithFormat:kKindergartenNewsListPath, @(kindergarten)];
    
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
                                   from:(NSInteger)fromId
                                     to:(NSInteger)toId
                                   most:(NSInteger)most
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kAssignmentListPath, @(kindergarten)];
    
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

- (void)reqGetChatingMsgsOfKindergarten:(NSInteger)kindergarten
                                   from:(NSInteger)fromId
                                     to:(NSInteger)toId
                                   most:(NSInteger)most
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSParameterAssert(_loginInfo.accountName);
    
    NSString* path = [NSString stringWithFormat:kChatingPath, @(kindergarten), _loginInfo.accountName];
    
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

- (void)reqSendChatingMsgs:(NSString*)msgBody
                 withImage:(NSString*)imgUrl
            toKindergarten:(NSInteger)kindergarten
              retrieveFrom:(NSInteger)fromId
                   success:(SuccessResponseHandler)success
                   failure:(FailureResponseHandler)failure {
    NSParameterAssert(msgBody || imgUrl); // 不能同时为空
    NSParameterAssert(_loginInfo);
    
    NSString* path = [NSString stringWithFormat:kChatingPath, @(kindergarten), _loginInfo.accountName];
    
    if (fromId >= 0) {
        path = [path stringByAppendingFormat:@"?retrieve_recent_from=%d", fromId];
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
                                 @"content": msgBody,
                                 @"image": msgImage,
                                 @"sender": _loginInfo.username};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
    
}

@end

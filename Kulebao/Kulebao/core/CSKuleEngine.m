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

@interface CSKuleEngine()

@property (strong, nonatomic) CSHttpClient* httpClient;

@end

@implementation CSKuleEngine
@synthesize httpClient = _httpClient;
@synthesize preferences = _preferences;
@synthesize loginInfo = _loginInfo;
@synthesize bindInfo = _bindInfo;
@synthesize relationships = _relationships;
@synthesize currentRelationship = _currentRelationship;

#pragma mark - application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
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
}

#pragma mark - Getter & Setter
- (void)setLoginInfo:(CSKuleLoginInfo *)loginInfo {
    _loginInfo = loginInfo;
    
    CSLog(@"%s\n%@", __FUNCTION__, loginInfo);
}

- (void)setBindInfo:(CSKuleBindInfo *)bindInfo {
    _bindInfo = bindInfo;
    
    CSLog(@"%s\n%@", __FUNCTION__, _bindInfo);
}

#pragma mark - Setup
- (void)setupEngine {
    [self setupHttpClient];
    [self setupPreferences];
    [self setupAppearance];
}

- (void)setupPreferences {
    _preferences = [CSKulePreferences defaultPreferences];
}

- (void)setupHttpClient {
    if (_httpClient == nil) {
        NSURL* baseUrl = [NSURL URLWithString:kServerHost];
        _httpClient = [CSHttpClient httpClientWithHost:baseUrl];
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

#pragma mark - HTTP Request
- (void)reqCheckPhoneNum:(NSString*)mobile
                 success:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure {
    
    [self setupHttpClient];
    
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
    
    [self setupHttpClient];
    
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
    [self setupHttpClient];
    
    NSString* path = kReceiveBindInfoPath;
    
    NSString* method = @"POST";
    
    NSDictionary* parameters = nil;
    
    if ([BPush getChannelId] && [BPush getUserId]) {
        parameters = @{@"phonenum": mobile,
                       @"user_id": [BPush getUserId],
                       @"channel_id": [BPush getChannelId],
                       @"device_type": @"ios"};
    }
    else {
        parameters = @{@"phonenum": mobile,
                       @"user_id": @"",
                       @"channel_id": @"",
                       @"device_type": @"ios"};
    }
    
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
    
    [self setupHttpClient];
    
    NSString* path = [NSString stringWithFormat:kGetFamilyRelationship, @(kindergarten)];

    NSString* method = @"GET";

    NSDictionary* parameters = @{@"parent": mobile};
    
    [_httpClient httpRequestWithMethod:method
                                  path:path
                            parameters:parameters
                               success:success
                               failure:failure];
}


@end

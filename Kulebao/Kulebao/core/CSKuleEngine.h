//
//  CSKuleEngine.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSHttpClient.h"

#import "CSKuleCommon.h"
#import "CSKuleEventType.h"
#import "CSKuleServerUrls.h"

#import "CSKuleLoginInfo.h"
#import "CSKuleBindInfo.h"
#import "CSKuleRelationshipInfo.h"

@interface CSKuleEngine : NSObject
@property (strong, nonatomic) CSKuleLoginInfo* loginInfo;
@property (strong, nonatomic) CSKuleBindInfo* bindInfo;
@property (strong, nonatomic) CSKuleRelationshipInfo* relationships;
@property (strong, nonatomic) CSKuleChildInfo* currentChild;

#pragma mark - application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

#pragma mark - Setup
- (void)setupHttpClient;
- (void)setupLocalData;


#pragma mark - HTTP Request
- (void)reqCheckPhoneNum:(NSString*)mobile
                 success:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure;

- (void)reqLogin:(NSString*)mobile
        withPswd:(NSString*)password
         success:(SuccessResponseHandler)success
         failure:(FailureResponseHandler)failure;

- (void)reqReceiveBindInfo:(NSString*)mobile
                   success:(SuccessResponseHandler)success
                   failure:(FailureResponseHandler)failure;

- (void)reqGetFamilyRelationship:(NSString*)mobile
                      inKindergarten:(NSInteger)kindergarten
                             success:(SuccessResponseHandler)success
                             failure:(FailureResponseHandler)failure;


@end

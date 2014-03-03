//
//  CSKuleEngine.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHttpClient.h"
#import "CSKuleLoginInfo.h"

@interface CSKuleEngine : NSObject
@property (strong, nonatomic) CSHttpClient* httpClient;

@property (strong, nonatomic) CSKuleLoginInfo* loginInfo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

- (void)setupHttpClient;
- (void)setupLocalData;

@end

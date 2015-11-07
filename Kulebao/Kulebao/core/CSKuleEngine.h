//
//  CSKuleEngine.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CBHttpClient.h"
#import "CSKuleCommon.h"
#import "CSKulePreferences.h"
#import "CSKuleInterpreter.h"
#import "hm_sdk.h"
#import "CBActivityData.h"

@interface CSKuleEngine : NSObject
@property (strong, nonatomic) CSKulePreferences* preferences;
@property (strong, nonatomic) CSKuleLoginInfo* loginInfo;

@property (strong, nonatomic) CBHttpClient* httpClient;

@property (strong, nonatomic) NSArray* relationships;
@property (strong, nonatomic) CSKuleRelationshipInfo* currentRelationship;

@property (strong, nonatomic, readonly) UIApplication* application;

@property (nonatomic, assign) NSInteger badgeOfNews;
@property (nonatomic, assign) NSInteger badgeOfRecipe;
@property (nonatomic, assign) NSInteger badgeOfCheckin;
@property (nonatomic, assign) NSInteger badgeOfSchedule;
@property (nonatomic, assign) NSInteger badgeOfAssignment;
@property (nonatomic, assign) NSInteger badgeOfChating;
@property (nonatomic, assign) NSInteger badgeOfAssess;

@property (nonatomic, assign) server_id hmServerId;
@property (nonatomic, strong) BMKLocationService* locService;

// For test only
@property (nonatomic, strong, readonly) NSMutableArray* receivedNotifications;
@property (nonatomic, strong) NSData* deviceToken;
@property (nonatomic, strong) NSDictionary* pendingNotificationInfo;

#pragma mark - application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - Setup
- (void)setupEngine;

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path;

#pragma mark - Core Data
// 初始化Core Data使用的数据库
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

// managedObjectModel的初始化赋值函数
-(NSManagedObjectModel *)managedObjectModel;

// managedObjectContext的初始化赋值函数
-(NSManagedObjectContext *)managedObjectContext;

#pragma mark - Retry
- (void)retryRequestOperationAfterBind:(AFHTTPRequestOperation*)operation;

#pragma mark - Check Updates
- (void)checkUpdatesOfNews;
- (void)checkUpdatesOfRecipe;
- (void)checkUpdatesOfCheckin;
- (void)checkUpdatesOfSchedule;
- (void)checkUpdatesOfAssignment;
- (void)checkUpdatesOfChating;
- (void)checkUpdatesOfAssess;

@end

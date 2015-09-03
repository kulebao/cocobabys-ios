//
//  CSKulePreferences.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSKuleLoginInfo.h"
#import "CSKuleBPushInfo.h"
#import "CSKuleNewsInfo.h"

@interface CSKulePreferences : NSObject
@property (nonatomic, strong) NSData* deviceToken;

@property (nonatomic, strong) NSString* defaultUsername;
@property (nonatomic, assign) BOOL guideShown;

@property (nonatomic, strong) CSKuleBPushInfo* baiduPushInfo;
@property (nonatomic, strong) CSKuleLoginInfo* loginInfo;
@property (nonatomic, strong, readonly) NSMutableDictionary* historyAccounts; // {mobile:date,}

@property (nonatomic, readonly) BOOL enabledTest;

@property (nonatomic, assign) BOOL enabledCommercial;

+ (id)defaultPreferences;

- (void)addHistoryAccount:(NSString*)account;

- (NSTimeInterval)timestampOfModule:(NSInteger)moduleType forChild:(NSString*)childId;

- (void)setTimestamp:(NSTimeInterval)timestamp ofModule:(NSInteger)moduleType forChild:(NSString*)childId;

- (void)setServerSettings:(NSDictionary*)settings;
- (NSDictionary*)getServerSettings;
- (NSArray*)getSupportServerSettingsList;

- (void)markNews:(CSKuleNewsInfo*)newsInfo;
- (BOOL)hasMarkedNews:(CSKuleNewsInfo*)newsInfo;

@end

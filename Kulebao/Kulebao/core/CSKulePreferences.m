//
//  CSKulePreferences.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKulePreferences.h"
#import "CSAppDelegate.h"

static NSString* kKeyDeviceToken = @"com.cocobabys.Kulebao.Preferences.deviceToken";
static NSString* kKeyDefaultUsername = @"com.cocobabys.Kulebao.Preferences.defaultUsername";
static NSString* kKeyGuideShown = @"com.cocobabys.Kulebao.Preferences.guideShown_v2.8";
static NSString* kKeyGuideHomeShown = @"com.cocobabys.Kulebao.Preferences.guideHomeShown_v2.8";
static NSString* kKeyLoginInfo = @"com.cocobabys.Kulebao.Preferences.loginInfo";
static NSString* kKeyBPushInfo = @"com.cocobabys.Kulebao.Preferences.baiduPushInfo";
static NSString* kKeyHistoryAccounts = @"com.cocobabys.Kulebao.Preferences.historyAccounts";
static NSString* kKeyTimestamps = @"com.cocobabys.Kulebao.Preferences.timestamps";
static NSString* kKeyServerSettings = @"com.cocobabys.Kulebao.Preferences.serverSettings";
static NSString* kKeyServerSettingsV2 = @"com.cocobabys.Kulebao.Preferences.serverSettings.v2";
static NSString* kKeyMarkedNews = @"com.cocobabys.Kulebao.Preferences.markedNews";
static NSString* kKeyCommercial = @"com.cocobabys.Kulebao.Preferences.commercial";
static NSString* kKeyRelationshipUID = @"com.cocobabys.Kulebao.Preferences.relationshipUID";

@implementation CSKulePreferences {
    NSUserDefaults* _config;
    NSMutableDictionary* _timestampDict;
    NSMutableSet* _markedNews;
}

@synthesize defaultUsername = _defaultUsername;
@synthesize guideShown = _guideShown;
@synthesize guideHomeShown = _guideHomeShown;
@synthesize loginInfo = _loginInfo;
@synthesize deviceToken = _deviceToken;
@synthesize historyAccounts = _historyAccounts;
@synthesize enabledTest = _enabledTest;
@synthesize enabledCommercial = _enabledCommercial;
@synthesize configTag = _configTag;

+ (id)defaultPreferences {
    static CSKulePreferences* s_preferences = nil;
    if (s_preferences == nil) {
        s_preferences = [CSKulePreferences new];
        [s_preferences loadPreferences];
    }
    return s_preferences;
}

- (id)init {
    if (self = [super init]) {
        _config = [NSUserDefaults standardUserDefaults];
        _timestampDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadPreferences {
    _deviceToken = [_config objectForKey:kKeyDeviceToken];
    _defaultUsername = [_config objectForKey:kKeyDefaultUsername];
    _guideShown = [[_config objectForKey:kKeyGuideShown] boolValue];
    _guideHomeShown = [[_config objectForKey:kKeyGuideHomeShown] boolValue];
    _enabledTest =  NO;//YES;// [[_config objectForKey:@"enabled_test"] boolValue];
    _configTag = [_config objectForKey:kKeyServerSettingsV2];
    _currentRelationshipUid = [[_config objectForKey:kKeyRelationshipUID] integerValue];

#if COCOBABYS_FEATURE_COMMERCIAL
    _enabledCommercial = [[_config objectForKey:kKeyCommercial] boolValue];
#else
    _enabledCommercial = NO;
#endif
    
    NSDictionary* loginInfoDict = [_config objectForKey:kKeyLoginInfo];
    CSKuleLoginInfo* loginInfo = [CSKuleLoginInfo new];
    
    loginInfo.accessToken = [loginInfoDict valueForKeyNotNull:@"accessToken"];
    loginInfo.accountName = [loginInfoDict valueForKeyNotNull:@"accountName"];
    loginInfo.schoolName = [loginInfoDict valueForKeyNotNull:@"schoolName"];
    loginInfo.username = [loginInfoDict valueForKeyNotNull:@"username"];
    loginInfo.schoolId = [[loginInfoDict valueForKeyNotNull:@"schoolId"] integerValue];
    loginInfo.errorCode = [[loginInfoDict valueForKeyNotNull:@"errorCode"] integerValue];
    loginInfo.memberStatus = [loginInfoDict valueForKeyNotNull:@"memberStatus"];
    loginInfo.imToken = [CBIMTokenData instanceWithDictionary:[loginInfoDict valueForKeyNotNull:@"imToken"]];
    
    if (loginInfo.accessToken && loginInfo.accountName && loginInfo.schoolName
        && loginInfo.username && loginInfo.schoolId!=0 && loginInfo.errorCode == 0) {
        _loginInfo = loginInfo;
    }
    else {
        _loginInfo = nil;
    }
    
    NSDictionary* bpushInfoDict = [_config objectForKey:kKeyBPushInfo];
    CSKuleBPushInfo* bpushInfo = [CSKuleBPushInfo new];
    bpushInfo.userId = [bpushInfoDict valueForKeyNotNull:@"userId"];
    bpushInfo.channelId = [bpushInfoDict valueForKeyNotNull:@"channelId"];
    bpushInfo.appId = [bpushInfoDict valueForKeyNotNull:@"appId"];
    
    if ([bpushInfo isValid]) {
        _baiduPushInfo = bpushInfo;
    }
    else {
        _baiduPushInfo = nil;
    }
    
    NSDictionary* timestamps = [_config objectForKey:kKeyTimestamps];
    if (timestamps) {
        _timestampDict = [NSMutableDictionary dictionaryWithDictionary:timestamps];
    }
    
    _historyAccounts = [[NSMutableDictionary alloc] initWithDictionary:[_config objectForKey:kKeyHistoryAccounts]];
    
    _markedNews = [NSMutableSet setWithArray:[_config objectForKey:kKeyMarkedNews]];
}

- (void)savePreferences {
    if (_deviceToken) {
        [_config setObject:_deviceToken forKey:kKeyDeviceToken];
    }
    else {
        [_config removeObjectForKey:kKeyDeviceToken];
    }
    
    if (_defaultUsername) {
        [_config setObject:_defaultUsername forKey:kKeyDefaultUsername];
    }
    else {
        [_config removeObjectForKey:kKeyDefaultUsername];
    }
    
    if (_guideShown) {
        [_config setObject:@(_guideShown) forKey:kKeyGuideShown];
    }
    else {
        [_config removeObjectForKey:kKeyGuideShown];
    }
    
    if (_guideHomeShown) {
        [_config setObject:@(_guideHomeShown) forKey:kKeyGuideHomeShown];
    }
    else {
        [_config removeObjectForKey:kKeyGuideHomeShown];
    }
    
    if (_enabledCommercial) {
        [_config setObject:@(_enabledCommercial) forKey:kKeyCommercial];
    }
    
    if (_loginInfo && _loginInfo.accessToken && _loginInfo.accountName && _loginInfo.schoolName
        && _loginInfo.username && _loginInfo.schoolId!=0 && _loginInfo.errorCode == 0) {
        NSDictionary* loginInfoDict = @{@"accessToken": SAFE_STRING(_loginInfo.accessToken),
                                        @"accountName": SAFE_STRING(_loginInfo.accountName),
                                        @"schoolName": SAFE_STRING(_loginInfo.schoolName),
                                        @"username": SAFE_STRING(_loginInfo.username),
                                        @"schoolId": @(_loginInfo.schoolId),
                                        @"errorCode": @(_loginInfo.errorCode),
                                        @"memberStatus": _loginInfo.memberStatus,
                                        @"imToken": (_loginInfo.imToken ? [_loginInfo.imToken dictionary] : @{})};

        [_config setObject:loginInfoDict forKey:kKeyLoginInfo];
    }
    else {
        [_config removeObjectForKey:kKeyLoginInfo];
    }
    
    if ([_baiduPushInfo isValid]) {
        NSDictionary* bpushInfoDict = @{@"userId": _baiduPushInfo.userId,
                                        @"channelId": _baiduPushInfo.channelId,
                                        @"appId": _baiduPushInfo.appId};
        
        [_config setObject:bpushInfoDict forKey:kKeyBPushInfo];
    }
    else {
        [_config removeObjectForKey:kKeyBPushInfo];
    }
    
    if (_historyAccounts) {
        [_config setObject:_historyAccounts forKey:kKeyHistoryAccounts];
    }
    else {
        [_config removeObjectForKey:kKeyHistoryAccounts];
    }
    
    if (_timestampDict) {
        [_config setObject:_timestampDict forKey:kKeyTimestamps];
    }
    else {
        [_config removeObjectForKey:kKeyTimestamps];
    }
    
    if (_markedNews) {
        [_config setObject:[_markedNews allObjects] forKey:kKeyMarkedNews];
    }
    else {
        [_config removeObjectForKey:kKeyMarkedNews];
    }
    
    if (_configTag) {
        [_config setObject:_configTag forKey:kKeyServerSettingsV2];
    }
    else {
        [_config removeObjectForKey:kKeyServerSettingsV2];
    }
    
    [_config setObject:@(_currentRelationshipUid) forKey:kKeyRelationshipUID];
    
    [_config synchronize];
}

#pragma mark - Setters
- (void)setCurrentRelationshipUid:(NSInteger)currentRelationshipUid {
    _currentRelationshipUid = currentRelationshipUid;
    [self savePreferences];
}

- (void)setConfigTag:(NSString *)configTag {
    _configTag = configTag;
    [self savePreferences];
}

- (NSString*)configTag {
    return _configTag;
}

- (void)setDefaultUsername:(NSString *)defaultUsername {
    _defaultUsername = defaultUsername;
    [self savePreferences];
}

- (void)setGuideShown:(BOOL)guideShown {
    _guideShown = guideShown;
    [self savePreferences];
}

- (void)setGuideHomeShown:(BOOL)guideHomeShown {
    _guideHomeShown = guideHomeShown;
    [self savePreferences];
}

- (void)setLoginInfo:(CSKuleLoginInfo *)loginInfo {
    _loginInfo = loginInfo;
    [self savePreferences];
}

- (void)setBaiduPushInfo:(CSKuleBPushInfo *)baiduPushInfo {
    _baiduPushInfo = baiduPushInfo;
    [self savePreferences];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    _deviceToken = deviceToken;
    [self savePreferences];
}

- (void)addHistoryAccount:(NSString*)account {
    if (account.length > 0) {
        if (_historyAccounts == nil) {
            _historyAccounts = [NSMutableDictionary dictionary];
        }
        
        [_historyAccounts setObject:[NSDate date] forKey:account];
        [self savePreferences];
    }
}

- (void)setEnabledCommercial:(BOOL)enabledCommercial {
#if COCOBABYS_FEATURE_COMMERCIAL
    if (enabledCommercial) {
        _enabledCommercial = enabledCommercial;
        [self savePreferences];
    }
#endif
}

- (BOOL)enabledCommercial {
    //return YES;
    return _enabledCommercial;
}

- (NSTimeInterval)timestampOfModule:(NSInteger)moduleType forChild:(NSString*)childId {
    NSTimeInterval ret = 0;
    if (childId.length > 0) {
        NSDictionary* childDict = [_timestampDict objectForKey:childId];
        if (childDict) {
            NSString* moduleName = [NSString stringWithFormat:@"Module_%ld", moduleType];
            NSNumber* value = [childDict objectForKey:moduleName];
            ret = [value doubleValue];
        }
    }
    return ret;
}

- (void)setTimestamp:(NSTimeInterval)timestamp ofModule:(NSInteger)moduleType forChild:(NSString*)childId{
    if (childId.length > 0) {
        NSDictionary* childDict = [_timestampDict objectForKey:childId];
        NSMutableDictionary* childMutDict = [NSMutableDictionary dictionaryWithDictionary:childDict];
        NSString* moduleName = [NSString stringWithFormat:@"Module_%@", @(moduleType)];
        [childMutDict setObject:@(timestamp) forKey:moduleName];
        [_timestampDict setObject:childMutDict forKey:childId];
        [self savePreferences];
    }
}

//- (void)setServerSettings:(NSDictionary*)settings {
//    if (settings) {
//        [_config setObject:settings forKey:kKeyServerSettings];
//        [_config synchronize];
//    }
//    else {
//        [_config removeObjectForKey:kKeyServerSettings];
//        [_config synchronize];
//    }
//}

//- (NSDictionary*)getServerSettings {
//    NSDictionary* settings = [_config objectForKey:kKeyServerSettings];
//    if (settings == nil) {
//        NSArray* serverList = [self getSupportServerSettingsList];
//        settings = serverList[0];
//    }
//    return settings;
//}

- (NSDictionary*)getServerSettings {
    NSArray* serverList = [self getSupportServerSettingsList];
    NSDictionary* settings = serverList.firstObject;
    
#if COCOBABYS_DEV_MODEL
    for (NSDictionary* s in serverList) {
        if ([_configTag isEqualToString:s[@"tag"]]) {
            settings = s;
            break;
        }
    }
#endif
    
    return settings;
}


- (NSArray*)getSupportServerSettingsList {
    //kangaroo103     coco999
    //dev: 9mzy6mOGMormOggT67K3jqBg
    //prod: O7Xwbt4DWOzsji57xybprqUc
    NSArray* serverList = @[@{@"name": @"产品服务器",
                              @"tag": @"prod",
                              @"url":@"https://www.cocobabys.com",
                              @"baidu_api_key":@"O7Xwbt4DWOzsji57xybprqUc",
                              @"rongyun_app_id":@"8w7jv4qb7tbqy",
                              @"rongyun_service_user_id": @"KEFU145027362547939"},
                            @{@"name": @"测试服务器",
                              @"tag": @"dev",
                              @"url":@"https://stage.cocobabys.com",
                              @"baidu_api_key":@"9mzy6mOGMormOggT67K3jqBg",
                              @"rongyun_app_id":@"0vnjpoadnwk0z",
                              @"rongyun_service_user_id": @"KEFU144879042344018"}];
    return serverList;
}

- (void)markNews:(CSKuleNewsInfo*)newsInfo {
    if (newsInfo && _markedNews) {
        CSKuleParentInfo* parentInfo = gApp.engine.currentRelationship.parent;
        
        NSString* key = [NSString stringWithFormat:@"%@-%@-%@",
                         @(parentInfo.schoolId),
                         @(newsInfo.newsId),
                         parentInfo.parentId];
        
        [_markedNews addObject:key];
        
        if (_markedNews) {
            [_config setObject:[_markedNews allObjects] forKey:kKeyMarkedNews];
        }
        else {
            [_config removeObjectForKey:kKeyMarkedNews];
        }
        
        [_config synchronize];
    }
}

- (BOOL)hasMarkedNews:(CSKuleNewsInfo*)newsInfo {
    BOOL ret = NO;
    if (newsInfo && _markedNews) {
        CSKuleParentInfo* parentInfo = gApp.engine.currentRelationship.parent;
        
        NSString* key = [NSString stringWithFormat:@"%@-%@-%@",
                         @(parentInfo.schoolId),
                         @(newsInfo.newsId),
                         parentInfo.parentId];
        
        ret = [_markedNews containsObject:key];
    }
    
    return ret;
}

@end

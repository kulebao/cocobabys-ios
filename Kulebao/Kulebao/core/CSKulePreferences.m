//
//  CSKulePreferences.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKulePreferences.h"

static NSString* kKeyDeviceToken = @"com.cocobabys.Kulebao.Preferences.deviceToken";
static NSString* kKeyDefaultUsername = @"com.cocobabys.Kulebao.Preferences.defaultUsername";
static NSString* kKeyGuideShown = @"com.cocobabys.Kulebao.Preferences.guideShown";
static NSString* kKeyLoginInfo = @"com.cocobabys.Kulebao.Preferences.loginInfo";
static NSString* kKeyBPushInfo = @"com.cocobabys.Kulebao.Preferences.baiduPushInfo";
static NSString* kKeyHistoryAccounts = @"com.cocobabys.Kulebao.Preferences.historyAccounts";

@implementation CSKulePreferences {
    NSUserDefaults* _config;
}

@synthesize defaultUsername = _defaultUsername;
@synthesize guideShown = _guideShown;
@synthesize loginInfo = _loginInfo;
@synthesize deviceToken = _deviceToken;
@synthesize historyAccounts = _historyAccounts;

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
    }
    return self;
}

- (void)loadPreferences {
    _deviceToken = [_config objectForKey:kKeyDeviceToken];
    _defaultUsername = [_config objectForKey:kKeyDefaultUsername];
    _guideShown = [[_config objectForKey:kKeyGuideShown] boolValue];
    
    
    NSDictionary* loginInfoDict = [_config objectForKey:kKeyLoginInfo];
    CSKuleLoginInfo* loginInfo = [CSKuleLoginInfo new];
    
    loginInfo.accessToken = [loginInfoDict valueForKeyNotNull:@"accessToken"];
    loginInfo.accountName = [loginInfoDict valueForKeyNotNull:@"accountName"];
    loginInfo.schoolName = [loginInfoDict valueForKeyNotNull:@"schoolName"];
    loginInfo.username = [loginInfoDict valueForKeyNotNull:@"username"];
    loginInfo.schoolId = [[loginInfoDict valueForKeyNotNull:@"schoolId"] integerValue];
    loginInfo.errorCode = [[loginInfoDict valueForKeyNotNull:@"errorCode"] integerValue];
    
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
    
    if (bpushInfo.userId && bpushInfo.channelId) {
        _baiduPushInfo = bpushInfo;
    }
    else {
        _baiduPushInfo = nil;
    }
    
    _historyAccounts = [_config objectForKey:kKeyHistoryAccounts];
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
    
    if (_loginInfo && _loginInfo.accessToken && _loginInfo.accountName && _loginInfo.schoolName
        && _loginInfo.username && _loginInfo.schoolId!=0 && _loginInfo.errorCode == 0) {
        NSDictionary* loginInfoDict = @{@"accessToken": _loginInfo.accessToken,
                                        @"accountName": _loginInfo.accountName,
                                        @"schoolName": _loginInfo.schoolName,
                                        @"username": _loginInfo.username,
                                        @"schoolId": @(_loginInfo.schoolId),
                                        @"errorCode": @(_loginInfo.errorCode)};

        [_config setObject:loginInfoDict forKey:kKeyLoginInfo];
    }
    else {
        [_config removeObjectForKey:kKeyLoginInfo];
    }
    
    if (_baiduPushInfo && _baiduPushInfo.userId && _baiduPushInfo.channelId) {
        NSDictionary* bpushInfoDict = @{@"userId": _baiduPushInfo.userId,
                                        @"channelId": _baiduPushInfo.channelId};
        
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

    [_config synchronize];
}

#pragma mark - Setters
- (void)setDefaultUsername:(NSString *)defaultUsername {
    _defaultUsername = defaultUsername;
    [self savePreferences];
}

- (void)setGuideShown:(BOOL)guideShown {
    _guideShown = guideShown;
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

@end

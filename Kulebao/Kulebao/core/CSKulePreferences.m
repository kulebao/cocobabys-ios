//
//  CSKulePreferences.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKulePreferences.h"

@implementation CSKulePreferences {
    NSUserDefaults* _config;
}

@synthesize defaultUsername = _defaultUsername;
@synthesize guideShown = _guideShown;
@synthesize loginUsername = _loginUsername;
@synthesize loginInfo = _loginInfo;

+ (id)defaultPreferences {
    CSKulePreferences* pre = [CSKulePreferences new];
    [pre loadPreferences];
    return pre;
}

- (id)init {
    if (self = [super init]) {
        _config = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)loadPreferences {
    _defaultUsername = [_config objectForKey:@"com.cocobabys.Kulebao.Preferences.defaultUsername"];
    _loginUsername = [_config objectForKey:@"com.cocobabys.Kulebao.Preferences.loginUsername"];
    _guideShown = [[_config objectForKey:@"com.cocobabys.Kulebao.Preferences.guideShown"] boolValue];
    
    CSKuleLoginInfo* loginInfo = [CSKuleLoginInfo new];
    loginInfo.accessToken = [_config objectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.accessToken"];
    loginInfo.accountName = [_config objectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.accountName"];
    loginInfo.schoolName = [_config objectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.schoolName"];
    loginInfo.username = [_config objectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.username"];
    loginInfo.schoolId = [[_config objectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.schoolId"] integerValue];
    loginInfo.errorCode = 0;
    
    if (loginInfo.accessToken && loginInfo.accountName && loginInfo.schoolName
        && loginInfo.username && loginInfo.schoolId!=0) {
        _loginInfo = loginInfo;
    }
    else {
        _loginInfo = nil;
    }
}

- (void)savePreferences {
    if (_defaultUsername) {
        [_config setObject:_defaultUsername forKey:@"com.cocobabys.Kulebao.Preferences.defaultUsername"];
    }
    else {
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.defaultUsername"];
    }
    
    if (_loginUsername) {
        [_config setObject:_loginUsername forKey:@"com.cocobabys.Kulebao.Preferences.loginUsername"];
    }
    else {
         [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.loginUsername"];
    }
    
    if (_guideShown) {
        [_config setObject:@(_guideShown) forKey:@"com.cocobabys.Kulebao.Preferences.guideShown"];
    }
    else {
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.guideShown"];
    }
    
    if (_loginInfo) {
        [_config setObject:_loginInfo.accessToken
                    forKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.accessToken"];
        [_config setObject:_loginInfo.accountName
                    forKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.accountName"];
        [_config setObject:_loginInfo.schoolName
                    forKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.schoolName"];
        [_config setObject:_loginInfo.username
                    forKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.username"];
        [_config setObject:@(_loginInfo.schoolId)
                    forKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.schoolId"];
    }
    else {
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.accessToken"];
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.accountName"];
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.schoolName"];
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.username"];
        [_config removeObjectForKey:@"com.cocobabys.Kulebao.Preferences.loginInfo.schoolId"];
    }
    
    [_config synchronize];
}

#pragma mark - Setters
- (void)setLoginUsername:(NSString *)loginUsername {
    _loginUsername = loginUsername;
    [self savePreferences];
}

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

@end

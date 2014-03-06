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
}

- (void)savePreferences {
    [_config setObject:_defaultUsername forKey:@"com.cocobabys.Kulebao.Preferences.defaultUsername"];
    [_config setObject:_loginUsername forKey:@"com.cocobabys.Kulebao.Preferences.loginUsername"];
    [_config setObject:@(_guideShown) forKey:@"com.cocobabys.Kulebao.Preferences.guideShown"];
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

@end

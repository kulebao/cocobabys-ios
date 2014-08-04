//
//  CSEngine.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSEngine.h"

NSString* kNotiLoginSuccess = @"noti.login.success";
NSString* kNotiUnauthorized = @"noti.unauthorized";

@implementation CSEngine
@synthesize loginInfo = _loginInfo;

+ (id)sharedInstance {
    static CSEngine* s_instance = nil;
    if (s_instance == nil) {
        s_instance = [CSEngine new];
    }
    
    return s_instance;
}

- (void)onLogin:(EntityLoginInfo*)loginInfo {
    _loginInfo = loginInfo;
}

@end

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

NSString* kKeyLoginAccount = @"key.login.account";


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

- (BOOL)encryptAccount:(ModelAccount*)account {
    BOOL ok = NO;
    if (account.username.length > 0 && account.password.length > 0) {
        NSUserDefaults* conf = [NSUserDefaults standardUserDefaults];
        
        [conf setObject:[NSKeyedArchiver archivedDataWithRootObject:account] forKey:kKeyLoginAccount];
        
        ok = [conf synchronize];
    }
    
    return ok;
}

- (ModelAccount*)decryptAccount {
    NSUserDefaults* conf = [NSUserDefaults standardUserDefaults];
    NSData* data = [conf objectForKey:kKeyLoginAccount];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (BOOL)clearAccount {
    NSUserDefaults* conf = [NSUserDefaults standardUserDefaults];
    [conf removeObjectForKey:kKeyLoginAccount];
    
    return [conf synchronize];
}

@end

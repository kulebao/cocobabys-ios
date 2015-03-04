//
//  CSEngine.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSEngine.h"
#import "AHAlertView.h"

NSString* kNotiLoginSuccess = @"noti.login.success";
NSString* kNotiLogoutSuccess = @"noti.logout.success";
NSString* kNotiUnauthorized = @"noti.unauthorized";
NSString* kKeyLoginAccount = @"key.login.account";

NSString* kAppleID = @"917314512";

@implementation CSEngine
@synthesize loginInfo = _loginInfo;

+ (id)sharedInstance {
    static CSEngine* s_instance = nil;
    if (s_instance == nil) {
        s_instance = [CSEngine new];
    }
    
    return s_instance;
}

- (void)setupAppearance {
    UIImage* imgAlertBg = [UIImage imageNamed:@"alert-bg.png"];
    UIImage* imgBtnBg = [UIImage imageNamed:@"btn-type1.png"];
    UIImage* imgBtnPressedBg = [UIImage imageNamed:@"btn-type1-pressed.png"];
    
    imgAlertBg = [imgAlertBg resizableImageWithCapInsets:UIEdgeInsetsMake(100, 50, 10, 50)];
    
    id alertAppearance = [AHAlertView appearance];
    [alertAppearance setBackgroundImage:imgAlertBg];
    [alertAppearance setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor],}];
    [alertAppearance setMessageTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor],}];
    [alertAppearance setButtonBackgroundImage:imgBtnBg forState:UIControlStateNormal];
    [alertAppearance setCancelButtonBackgroundImage:imgBtnBg forState:UIControlStateNormal];
    [alertAppearance setButtonBackgroundImage:imgBtnPressedBg forState:UIControlStateHighlighted];
    [alertAppearance setCancelButtonBackgroundImage:imgBtnPressedBg forState:UIControlStateHighlighted];
    [alertAppearance setContentInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
}

- (void)onLogin:(EntityLoginInfo*)loginInfo {
    _loginInfo = loginInfo;
}

- (void)onLoadClassInfoList:(NSArray*)classInfoList {
    _classInfoList = classInfoList;
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

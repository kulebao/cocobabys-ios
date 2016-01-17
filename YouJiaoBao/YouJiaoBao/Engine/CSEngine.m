//
//  CSEngine.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSEngine.h"
#import "AHAlertView.h"
#import "BaiduMobStat.h"
#import "CSHttpClient.h"

NSString* kNotiLoginSuccess = @"noti.login.success";
NSString* kNotiLogoutSuccess = @"noti.logout.success";
NSString* kNotiUnauthorized = @"noti.unauthorized";
NSString* kKeyLoginAccount = @"key.login.account";
NSString* kNotiShowLogin = @"noti.login.view";

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
    UIImage* imgBtnCancelBg = [[UIImage imageNamed:@"v2-btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    UIImage* imgBtnOkBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    imgAlertBg = [imgAlertBg resizableImageWithCapInsets:UIEdgeInsetsMake(100, 50, 10, 50)];
    
    id alertAppearance = [AHAlertView appearance];
    [alertAppearance setBackgroundImage:imgAlertBg];
    [alertAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [alertAppearance setMessageTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [alertAppearance setButtonBackgroundImage:imgBtnOkBg forState:UIControlStateNormal];
    [alertAppearance setCancelButtonBackgroundImage:imgBtnCancelBg forState:UIControlStateNormal];
    [alertAppearance setContentInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
}

- (void)setupBaiduMobStat {
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
#if COCOBABYS_DEV_MODEL
    statTracker.channelId = @"ios-dev";//设置您的app的发布渠道
#else
    statTracker.channelId = @"ios-appstore";//设置您的app的发布渠道
#endif
    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
    //statTracker.enableDebugOn = YES; //打开调试模式，发布时请去除此行代码或者设置为False即可。
    statTracker.logSendInterval = 1; //为1时表示发送日志的时间间隔为1小时,只有statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch这时才生效。
    statTracker.logSendWifiOnly = NO; //是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 15;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    [statTracker startWithAppId:@"9fbb516d10"];//设置您在mtj网站上添加的app的appkey
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

- (void)reloadSchoolInfo {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    if (_loginInfo) {
        [http opGetSchoolInfo:_loginInfo.schoolId.integerValue
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          _schoolInfo = [CBSchoolInfo instanceWithDictionary:responseObject];
                          
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          
                      }];
    }
}

@end

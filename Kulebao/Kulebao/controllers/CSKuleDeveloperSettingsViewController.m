//
//  CSKuleDeveloperSettingsViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/5/7.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleDeveloperSettingsViewController.h"
#import "BPush.h"
#import "CSKulePreferences.h"
#import "CSKuleEngine.h"
#import "CSAppDelegate.h"

@interface CSKuleDeveloperSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textLog;

@end

@implementation CSKuleDeveloperSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    CSKulePreferences* preference = [CSKulePreferences defaultPreferences];
    NSDictionary* serverInfo = [preference getServerSettings];
    
    NSString* serverInfoLog = [NSString stringWithFormat:@"服务器信息:\n名称：%@\n地址：%@", serverInfo[@"name"], serverInfo[@"url"]];
    
    NSString* baiduApiKey = serverInfo[@"baidu_api_key"];
    if (baiduApiKey.length > 4) {
        baiduApiKey = [baiduApiKey stringByReplacingCharactersInRange:NSMakeRange(2, baiduApiKey.length-4)
                                                           withString:@"********"];
    }
    
    NSString* baiduPushLog = [NSString stringWithFormat:@"百度推送信息：\napi_key:%@\napp_id:%@\nuser_id:%@\nchannel_id:%@", baiduApiKey, [BPush getAppId], [BPush getUserId], [BPush getChannelId]];
    
    NSMutableArray* logList = [NSMutableArray arrayWithArray: @[serverInfoLog, baiduPushLog]];
    
    if (gApp.engine.deviceToken) {
        [logList addObject:[NSString stringWithFormat:@"DeviceToken: %@", gApp.engine.deviceToken]];
    }
    
    if (gApp.engine.receivedNotifications.count > 0) {
        [logList addObject:@"Push Notifications:\n"];
        
        for (NSDictionary* userInfo in gApp.engine.receivedNotifications) {
            [logList addObject:[NSString stringWithFormat:@"%@", userInfo]];
        }
    }
    
    NSString* logText = [logList componentsJoinedByString:@"\n\n"];
    self.textLog.text = logText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  CSKuleDeveloperSettingsViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/5/7.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleDeveloperSettingsViewController.h"
#import "BPush.h"

@interface CSKuleDeveloperSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textLog;

@end

@implementation CSKuleDeveloperSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    NSString* baiduPushLog = [NSString stringWithFormat:@"百度推送信息：\napp_id:%@\nuser_id:%@\nchannel_id:%@", [BPush getAppId], [BPush getUserId], [BPush getChannelId]];
    
    self.textLog.text = baiduPushLog;
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

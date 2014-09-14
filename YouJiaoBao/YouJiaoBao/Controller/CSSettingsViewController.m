//
//  CSSettingsViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSSettingsViewController.h"
#import "AHAlertView.h"
#import "CSEngine.h"
#import "CSHttpClient.h"
#import "CSAppDelegate.h"

@interface CSSettingsViewController ()
- (IBAction)onBtnLogoutClicked:(id)sender;
- (IBAction)onBtnCheckUpdatesClicked:(id)sender;

@end

@implementation CSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnLogoutClicked:(id)sender {
    NSString *title = @"提示";
	NSString *message = @"确定要退出登录？";
	
	AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:@"取消" block:^{
	}];
    
	[alert addButtonWithTitle:@"确定" block:^{
        [self performSelector:@selector(doLogout) withObject:nil];
	}];
    
	[alert show];
}

- (IBAction)onBtnCheckUpdatesClicked:(id)sender {
    [self doCheckUpdates];
}

- (void)doLogout {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLogoutSuccess object:nil userInfo:nil];
}

- (void)doCheckUpdates {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSInteger resultCount = [[dataJson valueForKeyNotNull:@"resultCount"] integerValue];
        NSArray* results = [dataJson valueForKeyNotNull:@"results"];
        
        if (resultCount > 1) {
            NSDictionary* rightDic = [results firstObject];
            //获取appstore最新的版本号
            NSString *newVersion = [rightDic objectForKey:@"version"];
            //获取应用程序的地址
            NSString *newURL = [rightDic objectForKey:@"trackViewUrl"];
            NSDictionary *localDic =[[NSBundle mainBundle] infoDictionary];
            NSString *localVersion =[localDic objectForKey:@"CFBundleShortVersionString"];
            if ([localVersion isEqualToString:newVersion]) {
                [gApp alert:@"没有更新"];
            }
            else {
                NSString *title = @"新版本";
                NSString *message = @"发现新版本，是否前去更新？";
                AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
                
                [alert setCancelButtonTitle:@"取消" block:^{
                }];
                
                [alert addButtonWithTitle:@"确定" block:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newURL]];
                }];
                
                [alert show];
            }
        }
        else {
            CSLog(@"没有应用信息。");
            [gApp alert:@"没有更新"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
//        [gApp alert:[error localizedDescription]];
        [gApp alert:@"暂时无法获取版本信息"];
    };
    
    [gApp waitingAlert:@"正在检查更新..."];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    [http opCheckUpdates:kAppleID success:sucessHandler failure:failureHandler];
}

@end

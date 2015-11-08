//
//  CSKuleSettingsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleSettingsViewController.h"
#import "AHAlertView.h"
#import "CSAppDelegate.h"

@interface CSKuleSettingsViewController () {
}
@property (weak, nonatomic) IBOutlet UIButton *btnDevSettings;
- (IBAction)onBtnCheckUpdatesClicked:(id)sender;
- (IBAction)onBtnFeedbackClicked:(id)sender;
- (IBAction)onBtnChangePswdClicked:(id)sender;
- (IBAction)onBtnSelectChildClicked:(id)sender;
- (IBAction)onBtnAboutUsClicked:(id)sender;
- (IBAction)onBtnLogoutClicked:(id)sender;

@end

@implementation CSKuleSettingsViewController

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
    
    if (COCOBABYS_DEV_MODEL) {
        self.btnDevSettings.hidden = NO;
    }
    else {
        self.btnDevSettings.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UI Actions
- (IBAction)onBtnCheckUpdatesClicked:(id)sender {
    [self doCheckUpdates];
}

- (IBAction)onBtnFeedbackClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.feedback" sender:nil];
}

- (IBAction)onBtnChangePswdClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.changepswd" sender:nil];
}

- (IBAction)onBtnSelectChildClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.selectChild" sender:nil];
}

- (IBAction)onBtnAboutUsClicked:(id)sender {
     [self performSegueWithIdentifier:@"segue.about" sender:nil];
}

- (IBAction)onBtnLogoutClicked:(id)sender {
    NSString *title = @"提示";
	NSString *message = @"确定要退出登录？退出后无法接收任何消息！";
	
	AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:@"取消" block:^{
	}];
    
	[alert addButtonWithTitle:@"确定" block:^{
        [self performSelector:@selector(doLogout) withObject:nil];
	}];
    
	[alert show];
}

#pragma mark - Private
- (void)doLogout {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        if (bindInfo.errorCode == 0) {
            [gApp hideAlert];
        }
        else {
            CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
            [gApp alert:@"解除绑定失败。"];
        }
        
        [gApp logout];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
        [gApp logout];
    };
    
    [gApp waitingAlert:@"注销登录..."];
    [gApp.engine.httpClient reqUnbindWithSuccess:sucessHandler failure:failureHandler];
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
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"正在检查更新..."];
    [gApp.engine.httpClient reqCheckITunesUpdates:kKuleAppleID success:sucessHandler failure:failureHandler];
}

@end

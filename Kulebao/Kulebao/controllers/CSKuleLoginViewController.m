//
//  CSKuleLoginViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleLoginViewController.h"
#import "CSAppDelegate.h"
#import "BPush.h"

@interface CSKuleLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labNotice;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
- (IBAction)onBtnLoginClicked:(id)sender;

@end

@implementation CSKuleLoginViewController
@synthesize mobile = _mobile;

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
    self.navigationItem.title = @"登录密码";
    self.labNotice.text = [NSString stringWithFormat:@"尊敬的%@用户，您好！您的手机已经激活过，请输入密码进行登录，谢谢。", self.mobile];
    
    self.fieldPassword.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UI Actions
- (IBAction)onBtnLoginClicked:(id)sender {
    [self.fieldPassword resignFirstResponder];

    [self doLogin];
}

- (void)doLogin {
    NSString* pswd = self.fieldPassword.text;
    if (pswd.length > 0 && self.mobile.length > 0) {
        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            CSKuleLoginInfo* loginInfo = [CSKuleInterpreter decodeLoginInfo:dataJson];
            if (loginInfo.errorCode == 0) {
                gApp.engine.loginInfo = loginInfo;
                gApp.engine.preferences.loginInfo = loginInfo;
                [self performSelector:@selector(doReceiveBindInfo)
                           withObject:nil
                           afterDelay:0];
            }
            else {
                [gApp alert:@"密码错误，请重新输入,谢谢！" withTitle:@"提示"];
            }
        };
        
        FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
            CSLog(@"failure:%@", error);
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp waitingAlert:@"正在登录..."];
        [gApp.engine reqLogin:self.mobile
                     withPswd:pswd
                      success:sucessHandler
                      failure:failureHandler];
    }
    else {
        [gApp alert:@"请输入密码"];
    }
}

- (void)doReceiveBindInfo {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {

        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        
        if (bindInfo.errorCode == 0) {
            gApp.engine.loginInfo.schoolId = bindInfo.schoolId;
            gApp.engine.loginInfo.accessToken = bindInfo.accessToken;
            gApp.engine.loginInfo.accountName = bindInfo.accountName;
            gApp.engine.loginInfo.username = bindInfo.username;
            gApp.engine.loginInfo.schoolName = bindInfo.schoolName;
            
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            
            [gApp gotoMainProcess];
            [gApp hideAlert];
        }
        else {
            CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
            [gApp gotoLoginProcess];
            [gApp alert:@"绑定失败，请重新登录。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    [gApp waitingAlert:@"获取绑定信息..."];
    [gApp.engine reqReceiveBindInfo:gApp.engine.loginInfo.accountName
                  success:sucessHandler
                  failure:failureHandler];
}

@end

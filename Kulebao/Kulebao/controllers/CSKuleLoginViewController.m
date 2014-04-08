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
#import "CSKuleForgotPswdViewController.h"

@interface CSKuleLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labNotice;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
- (IBAction)onBtnLoginClicked:(id)sender;
- (IBAction)onBtnChangeAccountClicked:(id)sender;
- (IBAction)onBtnForgotPswdClicked:(id)sender;

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

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.forgotpswd"]) {
        CSKuleForgotPswdViewController* ctrl = segue.destinationViewController;
        ctrl.mobile = _mobile;
    }
}

#pragma mark - UI Actions
- (IBAction)onBtnLoginClicked:(id)sender {
    [self.fieldPassword resignFirstResponder];
    [self doLogin];
}

- (IBAction)onBtnChangeAccountClicked:(id)sender {
    [self.fieldPassword resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBtnForgotPswdClicked:(id)sender {
    [self.fieldPassword resignFirstResponder];
    
    if (_mobile.length > 0) {
        [self performSegueWithIdentifier:@"segue.forgotpswd" sender:nil];
    }
    else {
        [gApp alert:@"无效的手机号码，请退出重试。"];
    }
}

- (void)doLogin {
    NSString* pswd = self.fieldPassword.text;
    if (pswd.length > 0 && self.mobile.length > 0) {
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
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
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
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
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {

        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
        if (bindInfo.errorCode == 0) {
            gApp.engine.loginInfo.schoolId = bindInfo.schoolId;
            gApp.engine.loginInfo.accessToken = bindInfo.accessToken;
            gApp.engine.loginInfo.accountName = bindInfo.accountName;
            gApp.engine.loginInfo.username = bindInfo.username;
            gApp.engine.loginInfo.schoolName = bindInfo.schoolName;
            
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            
            [gApp.engine.preferences addHistoryAccount:gApp.engine.loginInfo.accountName];
            
            [gApp gotoMainProcess];
            [gApp hideAlert];
        }
        else if (bindInfo.errorCode == 1) {
            [gApp logout];
            [gApp alert:@"账号绑定失败，请重新登录。"];
        }
        else if (bindInfo.errorCode == 2) {
            [gApp logout];
            [gApp alert:@"账号未激活或已过期，请联系幼儿园处理，谢谢。"];
        }
        else if (bindInfo.errorCode == 3) {
            [gApp logout];
            [gApp alert:@"该手机号已经在其他手机上登录，为了您账号的安全，请修改密码后再重新登录。"];
        }
        else {
            [gApp logout];
            [gApp alert:@"账号绑定失败，请重新登录。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp logout];
        [gApp alert:error.localizedDescription];
    };

#if TARGET_IPHONE_SIMULATOR
    [gApp waitingAlert:@"获取绑定信息..."];
    [gApp.engine reqReceiveBindInfo:gApp.engine.loginInfo.accountName
                            success:sucessHandler
                            failure:failureHandler];
    
#else
    if ([gApp.engine.baiduPushInfo isValid]) {
        [gApp waitingAlert:@"获取绑定信息..."];
        [gApp.engine reqReceiveBindInfo:gApp.engine.loginInfo.accountName
                                success:sucessHandler
                                failure:failureHandler];
    }
    else {
        [gApp logout];
        [gApp alert:@"登录已过期，请重新登录。"];
    }
#endif
}

@end

//
//  CSLoginViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-7.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSLoginViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CSAppDelegate.h"
#import <RongIMKit/RongIMKit.h>
#import "CBSessionDataModel.h"

@interface CSLoginViewController () {
    ModelAccount* _loginAccount;
}

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UITextField *fieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
@property (weak, nonatomic) IBOutlet UILabel *labNote;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg2;

- (IBAction)onBtnLoginClicked:(id)sender;

@end

@implementation CSLoginViewController

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
    [self.navigationItem setHidesBackButton:YES];
    
    UIImage* fieldBgImg = [[UIImage imageNamed:@"v2-input_login.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    self.imgFieldBg2.image = fieldBgImg;
    UIImage* imgBtnGreenBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnLogin setBackgroundImage:imgBtnGreenBg forState:UIControlStateNormal];
    
    self.labNote.text = nil;
    
#ifdef DEBUG
#if COCOBABYS_USE_ENV_PROD
    self.fieldUsername.text = @"Joe_tian";
    self.fieldPassword.text = @"123456";
#else
    self.fieldUsername.text = @"admin8901";
    self.fieldPassword.text = @"89898989";
#endif
#endif
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

- (IBAction)onBtnLoginClicked:(id)sender {
    self.labNote.text = nil;
    [self hideKeyboard];
    
    NSString* username = self.fieldUsername.text;
    NSString* password = self.fieldPassword.text;
    
    if (username.length == 0) {
        self.labNote.text = @"请输入用户名";
        [self.fieldUsername becomeFirstResponder];
    }
    else if (password.length == 0) {
        self.labNote.text = @"请输入密码";
        [self.fieldPassword becomeFirstResponder];
    }
    else {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        
        id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            CBLoginInfo* loginInfo = [CBLoginInfo instanceWithDictionary:responseObject];
            if (loginInfo != nil) {
                CBSessionDataModel* session = [CBSessionDataModel session:loginInfo.phone];
                session.loginInfo = loginInfo;
                [session updateSchoolConfig:loginInfo.school_id.integerValue];
                [gApp alert:@"登录成功"];
                [[CSEngine sharedInstance] encryptAccount:_loginAccount];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLoginSuccess object:loginInfo userInfo:nil];
                
                [session reloadRelationships];
                [session reloadTeachers];
                
                if (loginInfo.im_token) {
                    // 快速集成第二步，连接融云服务器
                    [[RCIM sharedRCIM] connectWithToken:loginInfo.im_token.token
                                                success:^(NSString *userId) {
                                                    // Connect 成功
                                                    CSLog(@"[RCIM] connect success.");
                                                } error:^(RCConnectErrorCode status) {
                                                    // Connect 失败
                                                    CSLog(@"[RCIM] connect error.");
                                                } tokenIncorrect:^() {
                                                    // Token 失效的状态处理
                                                    CSLog(@"[RCIM] connect tokenIncorrect.");
                                                }];
                }
            }
            else {
//                self.labNote.text = @"用户名或密码错误";
                [gApp alert:@"用户名或密码错误"];
            }
        };
        
        id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
//            self.labNote.text = @"用户名或密码错误";
            if (operation.response) {
                [gApp alert:@"用户名或密码错误"];
            }
            else {
                [gApp alert:error.localizedDescription];
            }
        };
        
        _loginAccount = [ModelAccount accountWithUsername:username andPswd:password];
        
        [gApp waitingAlert:@"请稍候" withTitle:@"登录中"];
        [http opLoginWithUsername:username
                         password:password
                          success:success
                          failure:failure];
    }
}

#pragma mark - Private
- (void)hideKeyboard {
    [self.fieldUsername resignFirstResponder];
    [self.fieldPassword resignFirstResponder];
}

@end

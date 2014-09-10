//
//  CSLoginViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSLoginViewController.h"
#import "CSHttpClient.h"
#import "EntityLoginInfoHelper.h"
#import "CSEngine.h"
#import "CSAppDelegate.h"

@interface CSLoginViewController () {
    ModelAccount* _loginAccount;
}

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UITextField *fieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
@property (weak, nonatomic) IBOutlet UILabel *labNote;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"header.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont: [UIFont systemFontOfSize:20], UITextAttributeTextColor:[UIColor whiteColor]}];
    
    self.labNote.text = nil;
    self.fieldUsername.text = @"wx001";
    self.fieldPassword.text = @"123456";
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
            EntityLoginInfo* loginInfo = [EntityLoginInfoHelper updateEntity:responseObject];
            if (loginInfo != nil) {
                [gApp alert:@"登录成功"];
                [[CSEngine sharedInstance] encryptAccount:_loginAccount];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLoginSuccess object:loginInfo userInfo:nil];
            }
            else {
//                self.labNote.text = @"用户名或密码错误";
                [gApp alert:@"用户名或密码错误"];
            }
        };
        
        id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
//            self.labNote.text = @"用户名或密码错误";
            [gApp alert:@"用户名或密码错误"];
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

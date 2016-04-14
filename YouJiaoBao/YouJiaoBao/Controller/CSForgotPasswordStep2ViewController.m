//
//  CSForgotPasswordStep2ViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-5.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSForgotPasswordStep2ViewController.h"
#import "CSEngine.h"
#import "CSHttpClient.h"
#import "CSAppDelegate.h"
#import "NSString+CSKit.h"
#import <QuartzCore/QuartzCore.h>

@interface CSForgotPasswordStep2ViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UITextField *fieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *fieldVerifyCode;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswd;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswdAgain;
@property (weak, nonatomic) IBOutlet UIButton *btnResetPswd;
@property (weak, nonatomic) IBOutlet UIImageView *imgTextBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg2;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg3;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg4;

- (IBAction)onBtnResetPswdClicked:(id)sender;

@end

@implementation CSForgotPasswordStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    UIImage* fieldBgImg = [[UIImage imageNamed:@"v2-input_login.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    self.imgFieldBg2.image = fieldBgImg;
    self.imgFieldBg3.image = fieldBgImg;
    self.imgFieldBg4.image = fieldBgImg;
    UIImage* imgBtnGreenBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnResetPswd setBackgroundImage:imgBtnGreenBg forState:UIControlStateNormal];
    
    self.viewContainer.layer.cornerRadius = 4;
    self.viewContainer.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard {
    [self.fieldNewPswd resignFirstResponder];
    [self.fieldNewPswdAgain resignFirstResponder];
    [self.fieldUsername resignFirstResponder];
    [self.fieldVerifyCode resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnResetPswdClicked:(id)sender {
    [self hideKeyboard];
    if (self.fieldUsername.text.length == 0 ) {
        [gApp alert:@"无效用户名，请检查后重新输入，谢谢！"];
        self.fieldUsername.text = nil;
        [self.fieldUsername becomeFirstResponder];
    }
    else if (![self.fieldVerifyCode.text isValidSmsCode]) {
        [gApp alert:@"无效验证码，请检查后重新输入，谢谢！"];
        self.fieldVerifyCode.text = nil;
        [self.fieldVerifyCode becomeFirstResponder];
    }
    else if (![self.fieldNewPswd.text isValidPswd]) {
        [gApp alert:@"密码格式有误，请重新输入，谢谢！密码由数字或英文组成，长度6-16位。"];
        self.fieldNewPswd.text = nil;
        self.fieldNewPswdAgain.text = nil;
        [self.fieldNewPswd becomeFirstResponder];
    }
    else if (![self.fieldNewPswd.text isEqualToString:self.fieldNewPswdAgain.text]) {
        [gApp alert:@"2次密码输入不一致，请重新输入，谢谢！"];
    }
    else {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSInteger error_code = [[responseObject valueForKeyNotNull:@"error_code"] integerValue];
            if (error_code == 0) {
                [gApp alert:@"重置密码成功，请使用新密码登录，谢谢！"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiShowLogin
                                                                    object:nil
                                                                  userInfo:nil];
            }
            else {
                CSLog(@"opResetPswdOfAccount error_code=%ld", error_code);
                [gApp alert:@"重置密码失败！请确认用户名输入正确！"];
            }
        };
        
        id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [gApp alert:@"重置密码失败"];
        };
        
        [gApp waitingAlert:@"正在重置密码..."];
        [http opResetPswdOfAccount:self.fieldUsername.text
                       withNewPswd:self.fieldNewPswd.text
                       andAuthCode:self.fieldVerifyCode.text
                           success:success failure:failure];
    }
}

@end

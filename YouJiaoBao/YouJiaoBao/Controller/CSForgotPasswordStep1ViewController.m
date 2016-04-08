//
//  CSForgotPasswordStep1ViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-5.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSForgotPasswordStep1ViewController.h"
#import "CSEngine.h"
#import "CSHttpClient.h"
#import "CSAppDelegate.h"
#import "NSString+CSKit.h"

@interface CSForgotPasswordStep1ViewController ()

@property (nonatomic, strong) NSDate* lastSMSSentDate;
@property (nonatomic, strong) NSTimer* countdownTimer;

@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UITextField *fieldPhoneNumer;
@property (weak, nonatomic) IBOutlet UIButton *btnGetVerifyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)onBtnGetVerifyCodeClicked:(id)sender;
- (IBAction)onBtnNextClicked:(id)sender;

@end

@implementation CSForgotPasswordStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    
    UIImage* fieldBgImg = [[UIImage imageNamed:@"v2-input_login.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    UIImage* imgBtnGreenBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnGetVerifyCode setBackgroundImage:imgBtnGreenBg forState:UIControlStateNormal];
    [self.btnNext setBackgroundImage:imgBtnGreenBg forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard {
    [self.fieldPhoneNumer resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkTheTimer];
}

- (void)checkTheTimer {
    if (self.lastSMSSentDate) {
        if (![self.countdownTimer isValid]) {
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onCountdownFired:) userInfo:nil repeats:YES];
            self.btnGetVerifyCode.enabled = NO;
        }
        [self onCountdownFired:self.countdownTimer];
    }
    else {
        [self resetBtn];
    }
}

- (void)onCountdownFired:(NSTimer*)t {
    NSTimeInterval interval = [self.lastSMSSentDate timeIntervalSinceNow];
    
    const int kMaxSec = 600;
    
    if (interval < -kMaxSec || interval > 0) {
        [self resetBtn];
    }
    else {
        NSString* title = [NSString stringWithFormat:@"重新获取%d秒", ABS((int)(interval+kMaxSec))];
        [self.btnGetVerifyCode setTitle:title forState:UIControlStateNormal];
    }
}

- (void)resetBtn {
    self.lastSMSSentDate = nil;
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    
    self.btnGetVerifyCode.enabled = YES;
    [self.btnGetVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnGetVerifyCodeClicked:(id)sender {
    [self hideKeyboard];
    
    if ([self.fieldPhoneNumer.text isValidMobile]) {
        [self doGetSmsCode];
    }
    else {
        [gApp alert:@"手机号码格式有误，请重新输入"];
        [self.fieldPhoneNumer becomeFirstResponder];
    }
    
}

- (IBAction)onBtnNextClicked:(id)sender {
    [self hideKeyboard];
}

- (void)doGetSmsCode {
    NSString* phone = self.fieldPhoneNumer.text;
    if (phone.length > 0) {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            /* {"error_msg":"请求太频繁。","error_code":1} */
            
            //NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
            NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
            
            if (error_code == 0) {
                [gApp alert:@"验证码获取成功，将通过短信发送至手机，请注意查收短信。"];
                
                self.lastSMSSentDate = [NSDate date];
                [self checkTheTimer];
            }
            else {
                [gApp alert:@"验证码获取过于频繁，请稍后再试。"];
            }
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            if (operation.response.statusCode == 400) {
                [gApp alert:@"验证码未过期，请勿重复获取。"];
            }
            else {
                [gApp alert:@"获取验证码失败"];
            }
        };
        
        [gApp waitingAlert:@"正在获取验证码，请稍候..."];
        [http opGetSmsCode:phone
                   success:sucessHandler
                   failure:failureHandler];
    }
    else {
        [gApp alert:@"无效的手机号码"];
    }
}

@end

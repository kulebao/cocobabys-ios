//
//  CSKuleForgotPswdViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleForgotPswdViewController.h"
#import "CSAppDelegate.h"

static NSInteger kRetryInterval = 600; // 秒

@interface CSKuleForgotPswdViewController () {
    NSTimer* _timer;
    NSInteger _counter;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgConentBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg2;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg3;
@property (weak, nonatomic) IBOutlet UITextField *fieldSmsCode;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswd;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswdConfirm;
@property (weak, nonatomic) IBOutlet UITextView *textNotice;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoticeBg;
@property (weak, nonatomic) IBOutlet UIButton *btnRetrySmsCode;
- (IBAction)onBtnBackClicked:(id)sender;
- (IBAction)onBtnResetClicked:(id)sender;
- (IBAction)onBtnRetrySmsCodeClicked:(id)sender;

@end

@implementation CSKuleForgotPswdViewController
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
    
    self.imgConentBg.image = [[UIImage imageNamed:@"bg-dialog.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImage* fieldBgImg = [[UIImage imageNamed:@"bg-input-normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    self.imgFieldBg2.image = fieldBgImg;
    self.imgFieldBg3.image = fieldBgImg;
    self.imgNoticeBg.image = fieldBgImg;
    
    _timer = nil;
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

- (IBAction)onBtnBackClicked:(id)sender {
    [self hideKeyboard];
    
    [self goBack];
}

- (IBAction)onBtnResetClicked:(id)sender {
    /* 090724 */
    
    [self hideKeyboard];
    
    if (self.fieldSmsCode.text.length == 0) {
        [gApp alert:@"请输入短信验证码。"];
    }
    else if (self.fieldNewPswd.text.length == 0) {
        [gApp alert:@"请输入新密码。"];
    }
    else if (self.fieldNewPswdConfirm.text.length == 0) {
        [gApp alert:@"请再次输入新密码。"];
    }
    else if (![self.fieldNewPswd.text isEqualToString:self.fieldNewPswdConfirm.text]) {
        [gApp alert:@"两次输入的密码不一致。"];
    }
    else {
        [self doResetPswd];
    }
}

- (IBAction)onBtnRetrySmsCodeClicked:(id)sender {
    [self hideKeyboard];
    [self doGetSmsCode];
}

- (void)hideKeyboard {
    [self.fieldSmsCode resignFirstResponder];
    [self.fieldNewPswd resignFirstResponder];
    [self.fieldNewPswdConfirm resignFirstResponder];
}

#pragma mark - Private
- (void)startTimer {
    if (_timer == nil) {
        _counter = kRetryInterval;
        [self doCounting];
        
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimeOut:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;

    _counter = 0;
    [self doCounting];
}

- (void)onTimeOut:(NSTimer*)timer {
    --_counter;
    [self doCounting];
    
    if (_counter <= 0) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)doCounting {
    if (_counter > 0) {
        NSString* title = [NSString stringWithFormat:@"%d秒后重新获取", _counter];
        self.btnRetrySmsCode.enabled = NO;
        [self.btnRetrySmsCode setTitle:title
                              forState:UIControlStateDisabled];
    }
    else {
        [self.btnRetrySmsCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.btnRetrySmsCode.enabled = YES;
    }
}

- (void)goBack {
    [self stopTimer];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Request
- (void)doGetSmsCode {
    if (_mobile.length > 0) {
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            /* {"error_msg":"请求太频繁。","error_code":1} */
            
            NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
            NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
            
            if (error_code == 0) {
                [gApp alert:@"验证码已经发送，请注意查收短信。"];
                [self performSelector:@selector(startTimer) withObject:nil afterDelay:0];
            }
            else {
                [gApp alert:error_msg];
            }
        };

        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            if (operation.response.statusCode == 400) {
                [gApp alert:@"验证码未过期，请勿重复获取。"];
            }
            else {
                [gApp alert:[error localizedDescription]];
            }
        };
        
        [gApp waitingAlert:@"正在发送请求..."];
        [gApp.engine reqGetSmsCode:_mobile
                      success:sucessHandler
                      failure:failureHandler];
    }
    else {
        [gApp alert:@"无效的手机号码，请退出重试。"];
    }
}

- (void)doResetPswd {
    NSString* authCode = self.fieldSmsCode.text;
    NSString* newPswd = self.fieldNewPswd.text;
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        /* {"error_code":0,"access_token":"1393763572585"} */
        
        //NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
        NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
        NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
        
        if (error_code == 0) {
            [gApp alert:@"重置密码成功，请牢记新密码。"];
            [self goBack];
        }
        else {
            if (error_msg.length > 0) {
                [gApp alert:error_msg];
            }
            else {
                [gApp alert:@"短信验证码可能错误。" withTitle:@"重置密码失败"];
            }
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"正在发送请求..."];
    [gApp.engine reqResetPswd:_mobile
                      smsCode:authCode
                  withNewPswd:newPswd
                      success:sucessHandler
                      failure:failureHandler];
}

@end
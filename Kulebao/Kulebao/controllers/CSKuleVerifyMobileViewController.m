//
//  CSKuleVerifyMobileViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-3.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleVerifyMobileViewController.h"
#import "CSAppDelegate.h"

static NSInteger kRetryInterval = 120; // 秒

@interface CSKuleVerifyMobileViewController () {
    NSTimer* _timer;
    //NSInteger _counter;
    NSDate* _counterStart;
    NSString* _noticeTemp;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UITextField *fieldSmsCode;
@property (weak, nonatomic) IBOutlet UILabel *labNotice;
@property (weak, nonatomic) IBOutlet UIButton *btnRetrySmsCode;
@property (weak, nonatomic) IBOutlet UIButton *btnBind;
@property (weak, nonatomic) IBOutlet UIImageView *imgContentBg;

- (IBAction)onBtnBackClicked:(id)sender;
- (IBAction)onBtnBindClicked:(id)sender;
- (IBAction)onBtnRetrySmsCodeClicked:(id)sender;

@end

@implementation CSKuleVerifyMobileViewController
@synthesize mobile = _mobile;
@synthesize delegate = _delegate;

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
    self.imgContentBg.image = [[UIImage imageNamed:@"v2-input_login_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImage* fieldBgImg = [[UIImage imageNamed:@"v2-input_login.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    
    _noticeTemp = @"    尊敬的%@用户，您的手机已通过验证。请获取短信验证码并进行账号绑定，谢谢！\r\n\r\n特别提示：\r\n    该验证码的有效时间为2分钟，请在2分钟内进行绑定操作。";
    
    NSString* notice = [NSString stringWithFormat:_noticeTemp, _mobile];
    self.labNotice.text = notice;
    self.labNotice.font = [UIFont systemFontOfSize:13.0];
    
    UIImage* btnBgImage = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];

    [self.btnBind setBackgroundImage:btnBgImage
                            forState:UIControlStateNormal];
    
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

- (IBAction)onBtnBindClicked:(id)sender {
    /* 090724 */
    
    [self hideKeyboard];
    
    if (self.fieldSmsCode.text.length == 0) {
        [gApp alert:@"请输入短信验证码。"];
    }
    else if (![self.fieldSmsCode.text isValidSmsCode]) {
        [gApp alert:@"无效验证码，请检查后重新输入，谢谢。\n验证码为6位数字。"];
    }
    else {
        [self doBind];
    }
}

- (IBAction)onBtnRetrySmsCodeClicked:(id)sender {
    [self hideKeyboard];
    [self doGetSmsCode];
}

- (void)hideKeyboard {
    [self.fieldSmsCode resignFirstResponder];
}

#pragma mark - Private
- (void)startTimer {
    if (_timer == nil) {
        _counterStart = [NSDate date];
        [self doCounting];
        
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimeOut:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
    _counterStart = nil;

    [self doCounting];
}

- (void)onTimeOut:(NSTimer*)timer {
    [self doCounting];
}

- (void)doCounting {
    NSTimeInterval counter = [_counterStart timeIntervalSinceNow];
    NSInteger retrySecond = round(counter + kRetryInterval);
    
    if (retrySecond > 0) {
        NSString* title = [NSString stringWithFormat:@"(%@)秒", @(retrySecond)];
        self.btnRetrySmsCode.enabled = NO;
        [self.btnRetrySmsCode setTitle:title
                              forState:UIControlStateDisabled];
    }
    else {
        [_timer invalidate];
        _timer = nil;
        _counterStart = nil;
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
            
            //NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
            NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
            
            if (error_code == 0) {
                [gApp alert:@"验证码已经发送，请注意查收短信。"];
                [self performSelector:@selector(startTimer) withObject:nil afterDelay:0];
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
        
        [gApp waitingAlert:@"正在发送请求..."];
        [gApp.engine.httpClient reqGetSmsCode:_mobile
                           success:sucessHandler
                           failure:failureHandler];
    }
    else {
        [gApp alert:@"无效的手机号码，请退出重试。"];
    }
}

- (void)doBind {
    NSString* authCode = self.fieldSmsCode.text;
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
        NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
        
        if (error_code == 0) {
            [self stopTimer];
            
            if ([_delegate respondsToSelector:@selector(verifyMobileViewControllerDidFinished:)]) {
                [_delegate verifyMobileViewControllerDidFinished:self];
            }
        }
        else {
            [gApp alert:@"验证码错误，请重新输入，谢谢"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"正在发送请求..."];
#if COCOBABYS_USE_TEST_ACCOUNT
    dispatch_time_t then = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
 #ifdef DEBUG
    if ([authCode isEqualToString:@"235235"]) {
        dispatch_after(then, dispatch_get_main_queue(), ^{
            sucessHandler(nil, @{@"error_code":@(0), @"access_token":@"1393763572585"});
        });
    }
 #else
    if ([self.mobile isEqualToString:@"18782242007"] && [authCode isEqualToString:@"235235"]) {
        dispatch_after(then, dispatch_get_main_queue(), ^{
            sucessHandler(nil, @{@"error_code":@(0), @"access_token":@"1393763572585"});
        });
    }
 #endif
    else {
        [gApp.engine.httpClient reqBindPhone:_mobile
                          smsCode:authCode
                          success:sucessHandler
                          failure:failureHandler];
    }
#else
    [gApp.engine.httpClient reqBindPhone:_mobile
                      smsCode:authCode
                      success:sucessHandler
                      failure:failureHandler];
#endif
}


@end

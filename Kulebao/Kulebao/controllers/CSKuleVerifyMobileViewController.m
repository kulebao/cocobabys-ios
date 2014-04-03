//
//  CSKuleVerifyMobileViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleVerifyMobileViewController.h"
#import "CSAppDelegate.h"

static NSInteger kRetryInterval = 600; // 秒

@interface CSKuleVerifyMobileViewController () {
    NSTimer* _timer;
    NSInteger _counter;
    NSString* _noticeTemp;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgConentBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UITextField *fieldSmsCode;
@property (weak, nonatomic) IBOutlet UITextView *textNotice;
@property (weak, nonatomic) IBOutlet UIButton *btnRetrySmsCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoticeBg;
@property (weak, nonatomic) IBOutlet UIButton *btnBind;

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
    self.imgConentBg.image = [[UIImage imageNamed:@"bg-dialog.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImage* fieldBgImg = [[UIImage imageNamed:@"bg-input-normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    self.imgNoticeBg.image = fieldBgImg;
    
    _noticeTemp = @"您的手机号码%@已通过验证，请点击获取验证码按钮，稍后会有一个6位数字的验证码，通过短信发送到该手机上，请在下方的输入框内填入此验证码，点击绑定按钮，进行手机绑定，谢谢。\n\n特别提示：该验证码的有效时间为10分钟，请在有效时间内进行绑定操作。";
    
    NSString* notice = [NSString stringWithFormat:_noticeTemp, _mobile];
    self.textNotice.text = notice;
    self.textNotice.textColor = UIColorRGB(0xff, 0x33, 0x00);
    self.textNotice.font = [UIFont systemFontOfSize:13.0];
    
    UIImage* btnBgImage = [[UIImage imageNamed:@"btn-type1.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage* btnBgImagePressed = [[UIImage imageNamed:@"btn-type1-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];

    [self.btnBind setBackgroundImage:btnBgImage
                            forState:UIControlStateNormal];
    [self.btnBind setBackgroundImage:btnBgImagePressed
                            forState:UIControlStateHighlighted];
    
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

- (void)doBind {
    NSString* authCode = self.fieldSmsCode.text;
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        /* {"error_code":0,"access_token":"1393763572585"} */
        
        //NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
        NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
        NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
        
        if (error_code == 0) {
            [self stopTimer];
            
            if ([_delegate respondsToSelector:@selector(verifyMobileViewControllerDidFinished:)]) {
                [_delegate verifyMobileViewControllerDidFinished:self];
            }
        }
        else {
            if (error_msg.length > 0) {
                [gApp alert:error_msg];
            }
            else {
                [gApp alert:@"短信验证码可能错误。" withTitle:@"绑定失败"];
            }
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"正在发送请求..."];
    [gApp.engine reqBindPhone:_mobile
                      smsCode:authCode
                      success:sucessHandler
                      failure:failureHandler];
}


@end

//
//  CSKuleLoginViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleLoginViewController.h"
#import "CSAppDelegate.h"

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
    self.labNotice.text = [NSString stringWithFormat:@"尊敬的%@用户，您好！您的手机已经激活过，请输入密码进行登录，谢谢。", self.mobile];
    
    self.fieldPassword.text = @"1q2w3e";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions
- (IBAction)onBtnLoginClicked:(id)sender {
    [self.fieldPassword resignFirstResponder];
    
    [self doLogin];
}

- (void)doLogin {
    NSString* pswd = self.fieldPassword.text;
    if (pswd.length > 0 && self.mobile.length > 0) {
        
        NSDictionary* params = @{@"account_name":self.mobile,
                                 @"password":pswd};

        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            CSLog(@"success:%@", dataJson);
            
            NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
            NSString* account_name = [dataJson valueForKeyNotNull:@"account_name"];
            NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
            NSString* school_name = [dataJson valueForKeyNotNull:@"school_name"];
            NSString* username = [dataJson valueForKeyNotNull:@"username"];
            
            if (error_code == 0) {
                CSKuleLoginInfo* loginInfo = [CSKuleLoginInfo new];
                loginInfo.accessToken = access_token;
                loginInfo.accountName = account_name;
                loginInfo.schoolName = school_name;
                loginInfo.username = username;
                
                gApp.engine.loginInfo = loginInfo;

                [gApp gotoMainProcess];
                [gApp alert:@"登录成功"];
            }
            else {
                [gApp alert:@"密码错误，请重新输入,谢谢！" withTitle:@"提示"];
            }
        };
        
        FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
            NSLog(@"failure:%@", error);
        };
        
        [gApp waitingAlert:@"正在登录..."];
        
        [gApp.engine.httpClient httpRequestWithMethod:@"POST"
                                                 path:kLoginPath
                                           parameters:params
                                              success:sucessHandler
                                              failure:failureHandler];
    }
    else {
        
    }
}

@end

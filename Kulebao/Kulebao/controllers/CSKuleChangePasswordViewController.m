//
//  CSKuleChangePasswordViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-20.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleChangePasswordViewController.h"
#import "CSAppDelegate.h"
#import <UIAlertView+BlocksKit.h>

@interface CSKuleChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fieldOldPswd;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswd;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswdAgain;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg1;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg2;
@property (weak, nonatomic) IBOutlet UIImageView *imgFieldBg3;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

- (IBAction)onBtnChangePswdClicked:(id)sender;

@end

@implementation CSKuleChangePasswordViewController

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
    
    
    UIImage* fieldBgImg = [[UIImage imageNamed:@"v2-input_login.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.imgFieldBg1.image = fieldBgImg;
    self.imgFieldBg2.image = fieldBgImg;
    self.imgFieldBg3.image = fieldBgImg;
    UIImage* imgBtnGreenBg = [[UIImage imageNamed:@"v2-btn_green.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnSubmit setBackgroundImage:imgBtnGreenBg forState:UIControlStateNormal];
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

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UI actions
- (IBAction)onBtnChangePswdClicked:(id)sender {
    NSString* oldPswd = self.fieldOldPswd.text;
    NSString* newPswd = self.fieldNewPswd.text;
    NSString* newPswdAgain = self.fieldNewPswdAgain.text;
    
    if (oldPswd.length == 0) {
        [self.fieldOldPswd becomeFirstResponder];
        [gApp alert:@"请输入旧密码"];
    }
    else if (newPswd.length == 0) {
        [self.fieldNewPswd becomeFirstResponder];
        [gApp alert:@"请输入新密码，密码由数字或英文组成，长度是6-16位。"];
    }
    else if (![newPswd isValidPswd]) {
        [self.fieldNewPswd becomeFirstResponder];
        [gApp alert:@"密码格式有误，请重新输入，谢谢。\n密码由数字或英文组成，长度是6-16位。"];
    }
    else if (newPswdAgain.length == 0) {
        [self.fieldNewPswdAgain becomeFirstResponder];
        [gApp alert:@"请再次输入新密码，密码由数字或英文组成，长度是6-16位。"];
    }
    else if (![newPswdAgain isValidPswd]) {
        [self.fieldNewPswdAgain becomeFirstResponder];
        [gApp alert:@"密码格式有误，请重新输入，谢谢。 \n密码由数字或英文组成，长度是6-16位。"];
    }
    else if (![newPswdAgain isEqualToString:newPswd]) {
        [self.fieldNewPswdAgain becomeFirstResponder];
        [gApp alert:@"两次输入的新密码不一致"];
    }
    else if (gApp.engine.preferences.localPswd &&
             ![gApp.engine.preferences.localPswd isEqualToString:[oldPswd MD5Hash]]) {
        [self.fieldOldPswd becomeFirstResponder];
        [gApp alert:@"修改密码失败"];
    }
    else {
        [self hideKeyboard];
        [self doChangePswd:newPswd withOldPswd:oldPswd];
    }
}

- (void)doChangePswd:(NSString*)newPswd withOldPswd:(NSString*)oldPswd {
    NSParameterAssert(newPswd);
    NSParameterAssert(oldPswd);
    
    SuccessResponseHandler sucessHandler = ^(NSURLSessionDataTask *task, id dataJson) {
        NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
        NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
        
        if (error_code == 0) {
            gApp.engine.loginInfo.accessToken = access_token;
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            
            [self performSelectorOnMainThread:@selector(doChangePswdSuccess) withObject:nil waitUntilDone:NO];
        }
        else {
            CSLog(@"doChangePswd error_code=%ld", (long)error_code);
            [gApp alert:@"修改密码失败"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(NSURLSessionDataTask *task, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
    };
    
    [gApp waitingAlert:@"修改密码中..."];
    [gApp.engine.httpClient reqChangePassword:newPswd
                       withOldPswd:oldPswd
                           success:sucessHandler
                           failure:failureHandler];
}

- (void)doChangePswdSuccess {
    UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:@"修改成功" message:@"密码已修改，需要重新登录"];
    [alert bk_addButtonWithTitle:@"好的" handler:^{
        [gApp gotoLoginProcess];
    }];
    
    [alert show];
    
//    [gApp alert:@"修改成功。"];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboard {
    [self.fieldNewPswd resignFirstResponder];
    [self.fieldNewPswdAgain resignFirstResponder];
    [self.fieldOldPswd resignFirstResponder];
}

@end

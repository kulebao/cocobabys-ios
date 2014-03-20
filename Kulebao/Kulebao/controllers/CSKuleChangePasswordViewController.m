//
//  CSKuleChangePasswordViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-20.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChangePasswordViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fieldOldPswd;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswd;
@property (weak, nonatomic) IBOutlet UITextField *fieldNewPswdAgain;
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
    [self customizeBackBarItem];
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

#pragma mark - UI actions
- (IBAction)onBtnChangePswdClicked:(id)sender {
    NSString* oldPswd = self.fieldOldPswd.text;
    NSString* newPswd = self.fieldNewPswd.text;
    NSString* newPswdAgain = self.fieldNewPswdAgain.text;
    
    if (oldPswd.length == 0) {
        [gApp alert:@"请输入旧密码"];
    }
    else if (newPswd.length == 0) {
        [gApp alert:@"请输入新密码"];
    }
    else if (newPswdAgain.length == 0) {
        [gApp alert:@"请再次输入新密码"];
    }
    else if (![newPswdAgain isEqualToString:newPswd]) {
        [gApp alert:@"两次输入的新密码不一致"];
    }
    else {
        [self hideKeyboard];
        [self doChangePswd:newPswd withOldPswd:oldPswd];
    }
}

- (void)doChangePswd:(NSString*)newPswd withOldPswd:(NSString*)oldPswd {
    NSParameterAssert(newPswd);
    NSParameterAssert(oldPswd);
    
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
        NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
        
        if (error_code == 0) {
            gApp.engine.loginInfo.accessToken = access_token;
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            
            [gApp alert:@"修改成功。"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            CSLog(@"doChangePswd error_code=%d", error_code);
            [gApp alert:@"修改密码失败。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
    };
    
    [gApp waitingAlert:@"修改密码中..."];
    [gApp.engine reqChangePassword:newPswd
                       withOldPswd:oldPswd
                           success:sucessHandler
                           failure:failureHandler];
}

- (void)hideKeyboard {
    [self.fieldNewPswd resignFirstResponder];
    [self.fieldNewPswdAgain resignFirstResponder];
    [self.fieldOldPswd resignFirstResponder];
}

@end

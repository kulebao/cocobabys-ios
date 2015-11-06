//
//  CBAddFamilyViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/27/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBAddFamilyViewController.h"
#import "CSAppDelegate.h"
#import "UIButton+Countdown.h"
#import "CSTextFieldDelegate.h"
#import "CBShareIntroView.h"

@interface CBAddFamilyViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fieldPhone;
@property (weak, nonatomic) IBOutlet UITextField *fieldPasscode;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPasscode;
@property (weak, nonatomic) IBOutlet UITextField *fieldName;
@property (weak, nonatomic) IBOutlet UITextField *fieldRelationship;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;

@property (nonatomic, strong) CSTextFieldDelegate* fieldDelegate;
@property (nonatomic, strong) CBShareIntroView* shareIntroView;

- (IBAction)onBtnGetPasscodeClicked:(id)sender;
- (IBAction)onBtnInviteClicked:(id)sender;
- (IBAction)onBtnShareClicked:(id)sender;

@end

@implementation CBAddFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    self.fieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    self.fieldDelegate.maxLength = 20;
    
    self.fieldName.delegate = self.fieldDelegate;
    self.fieldRelationship.delegate = self.fieldDelegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnGetPasscodeClicked:(id)sender {
    [self closeKeyboard];
    
    [self onGetInviteCode];
}

- (IBAction)onBtnShareClicked:(id)sender {
    [self showIntroViews];
}

- (IBAction)onBtnInviteClicked:(id)sender {
    [self closeKeyboard];
    
    if ([self checkInputs]) {
        NSString* name = [self.fieldName.text trim];
        NSString* passcode = [self.fieldPasscode.text trim];
        NSString* phone = [self.fieldPhone.text trim];
        NSString* relationship = [self.fieldRelationship.text trim];
        
        [gApp waitingAlert:@"正在发送邀请"];
        [gApp.engine reqCreateInvitationOfKindergarten:gApp.engine.loginInfo.schoolId
                                                 phone:phone
                                                  name:name
                                          relationship:relationship
                                              passcode:passcode
                                               success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                                   if ([dataJson isKindOfClass:[NSDictionary class]]) {
                                                       NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                                       NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                                                       
                                                       if (error_code == 4) {
                                                           // ERR_INVITEE_PHONE_INVALID
                                                           [gApp alert:@"被邀请手机号码无效，请检查"];
                                                       }
                                                       else {
                                                           [gApp alert:@"邀请成功"];
                                                           [self showIntroViews];
                                                       }
                                                   }
                                                   else {
                                                       [gApp alert:@"邀请成功"];
                                                       [self showIntroViews];
                                                   }
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   NSError* err = nil;
                                                   id dataJson = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&err];
                                                   if (dataJson && !err) {
                                                       NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                                       NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                                                       if (error_code == 1) {
                                                           // AUTH_CODE_IS_INVALID
                                                           [gApp alert:@"验证码错误，请重新输入，谢谢！"];
                                                       }
                                                       else if (error_code == 20) {
                                                           // INVITE_PHONE_ALREADY_EXIST
                                                           [gApp alert:@"手机号已经注册,邀请失败"];
                                                       }
                                                       else {
                                                           // INVITE_FAIL
                                                           [gApp alert:@"邀请失败"];
                                                       }
                                                   }
                                                   else {
                                                       [gApp alert:@"邀请失败"];
                                                   }
                                               }];
    }
}

- (BOOL)checkInputs {
    BOOL ok = YES;
    
    NSString* name = [self.fieldName.text trim];
    self.fieldName.text = name;
    
    NSString* passcode = [self.fieldPasscode.text trim];
    self.fieldPasscode.text = passcode;
    
    NSString* phone = [self.fieldPhone.text trim];
    self.fieldPhone.text = phone;

    NSString* relationship = [self.fieldRelationship.text trim];
    self.fieldRelationship.text = relationship;
    
    if (![phone isValidMobile]) {
        ok = NO;
        [gApp alert:@"无效手机号码，请检查后重新输入，谢谢!"];
    }
    else if (![passcode isValidSmsCode]) {
        ok = NO;
        [gApp alert:@"无效验证码,请检查后重新输入，谢谢!"];
    }
    else if (name.length <= 0) {
        ok = NO;
        [gApp alert:@"姓名不能为空"];
    }
    else if (relationship.length <= 0) {
        ok = NO;
        [gApp alert:@"关系不能为空"];
    }
    
    return ok;
}

- (void)closeKeyboard {
    [self.fieldName resignFirstResponder];
    [self.fieldPasscode resignFirstResponder];
    [self.fieldPhone resignFirstResponder];
    [self.fieldRelationship resignFirstResponder];
}

- (CBShareIntroView*)shareIntroView {
    if (_shareIntroView == nil) {
        _shareIntroView = [CBShareIntroView instance];
    }
    
    return _shareIntroView;
}

-(void)showIntroViews {
    [self.shareIntroView showInView:self.navigationController.view];
}

- (void)onGetInviteCode {
    NSString* phone = [self.fieldPhone.text trim];
    self.fieldPhone.text = phone;
    if (![phone isValidMobile]) {
        [gApp alert:@"无效手机号码，请检查后重新输入，谢谢!"];
    }
    else {
        [gApp.engine reqGetInviteCodeWithHost:gApp.engine.currentRelationship.parent.phone
                                   andInvitee:phone
                                      success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                          NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                          NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                                          if (error_code == 4) {
                                              // INVITE_PHONE_INVALID
                                              [gApp alert:@"被邀请手机号码无效，请检查"];
                                          }
                                          else {
                                              [gApp alert:@"获取验证码成功，稍后会用短信将该验证码发送到您的手机上，谢谢"];
                                              
                                              [self.btnGetPasscode startTimer:120 callback:^(NSInteger i) {
                                                  self.btnGetPasscode.enabled = YES;
                                                  [self.btnGetPasscode setTitle:[NSString stringWithFormat:@"重新获取%ld秒", i] forState:UIControlStateNormal];
                                                  self.btnGetPasscode.enabled = NO;
                                              } timeout:^{
                                                  self.btnGetPasscode.enabled = YES;
                                                  [self.btnGetPasscode setTitle:@"获取邀请码" forState:UIControlStateNormal];
                                              }];
                                          }
                                          
                                          CSLog(@"%@", dataJson);
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          CSLog(@"%@", error);
                                          NSError* err = nil;
                                          id dataJson = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&err];
                                          if (dataJson && !err) {
                                              NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                              NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                                              if (error_code == 1) {
                                                  // GET_AUTH_CODE_TOO_OFTEN
                                                  [gApp alert:@"验证码获取过于频繁，请稍后再试"];
                                              }
                                              else if (error_code == 8) {
                                                  [gApp alert:@"被邀请人已经在幼乐宝注册"];
                                              }
                                              else {
                                                  // GET_AUTH_CODE_FAIL
                                                  [gApp alert:@"获取验证码失败"];
                                              }
                                          }
                                          else {
                                              [gApp alert:@"获取邀请码失败"];
                                          }
                                      }];
    }
}

@end

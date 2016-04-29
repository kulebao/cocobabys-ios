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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CBAddFamilyViewController () <ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fieldPhone;
@property (weak, nonatomic) IBOutlet UITextField *fieldPasscode;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPasscode;
@property (weak, nonatomic) IBOutlet UITextField *fieldName;
@property (weak, nonatomic) IBOutlet UITextField *fieldRelationship;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UIButton *btnPickContact;

@property (nonatomic, strong) CSTextFieldDelegate* fieldDelegate;
@property (nonatomic, strong) CBShareIntroView* shareIntroView;
@property (nonatomic, strong) ABPeoplePickerNavigationController* peoplePicker;

- (IBAction)onBtnGetPasscodeClicked:(id)sender;
- (IBAction)onBtnInviteClicked:(id)sender;
- (IBAction)onBtnShareClicked:(id)sender;
- (IBAction)onBtnPickContactClicked:(id)sender;

@end

@implementation CBAddFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.fieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    self.fieldDelegate.maxLength = kKuleRelationshipMaxLength;
    
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
    [self closeKeyboard];
    [self showIntroViews];
}

- (IBAction)onBtnPickContactClicked:(id)sender {
    [self closeKeyboard];
    ABAddressBookRef addressBook = nil;
    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block BOOL allowed = NO;
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 allowed = granted;
                                                 dispatch_semaphore_signal(sema);
                                             });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (allowed) {
        self.peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
        self.peoplePicker.peoplePickerDelegate = self;
        self.peoplePicker.delegate = self;
        self.peoplePicker.displayedProperties = @[@(kABPersonPhoneProperty)];
        
        if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
            self.peoplePicker.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:NO];
        }
        
        [self presentViewController:self.peoplePicker animated:YES completion:^{
            
        }];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未授权通讯录"
                                                            message:@"请修改手机设置，允许[幼乐宝]访问通讯录：打开[设置]进入[隐私]选项，选择[通讯录]，打开[幼乐宝]的通讯录权限。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)onBtnInviteClicked:(id)sender {
    [self closeKeyboard];
    
    if ([self checkInputs]) {
        NSString* name = [self.fieldName.text trim];
        NSString* passcode = [self.fieldPasscode.text trim];
        NSString* phone = [self.fieldPhone.text trim];
        NSString* relationship = [self.fieldRelationship.text trim];
        
        [gApp waitingAlert:@"正在发送邀请"];
        [gApp.engine.httpClient reqCreateInvitationOfKindergarten:gApp.engine.loginInfo.schoolId
                                                 phone:phone
                                                  name:name
                                          relationship:relationship
                                              passcode:passcode
                                               success:^(NSURLSessionDataTask *task, id dataJson) {
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
                                               failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                   NSError* err = nil;
                                                    NSData* responseData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
                                                   id dataJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
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
        [gApp waitingAlert:@"正在向被邀请人发送邀请码"];
        [gApp.engine.httpClient reqGetInviteCodeWithHost:gApp.engine.currentRelationship.parent.phone
                                   andInvitee:phone
                                      success:^(NSURLSessionDataTask *task, id dataJson) {
                                          NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                          NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                                          if (error_code == 4) {
                                              // INVITE_PHONE_INVALID
                                              [gApp alert:@"被邀请手机号码无效，请检查"];
                                          }
                                          else {
                                              [gApp alert:@"邀请码发送成功，请在20分钟内向被邀请人索取，谢谢！"];
                                              
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
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          CSLog(@"%@", error);
                                          NSError* err = nil;
                                          NSData* responseData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
                                          id dataJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
                                          if (dataJson && !err) {
                                              NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                              NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                                              if (error_code == 1) {
                                                  // GET_AUTH_CODE_TOO_OFTEN
                                                  [gApp alert:@"验证码获取过于频繁，请稍后再试"];
                                              }
                                              else if (error_code == 8) {
                                                  [gApp alert:@"获取邀请码失败，被邀请人已经在幼乐宝注册"];
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

#pragma mark - ABPeoplePickerNavigationControllerDelegate
// Called after a person has been selected by the user. // IOS8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {

}

// Called after a property has been selected by the user. // IOS8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone, identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    CSLog(@"Select -> %@", phoneNO);
    if ([phoneNO isValidMobile]) {
        self.fieldPhone.text = phoneNO;
        //if ([self.fieldName.text trim].length == 0) {
            self.fieldName.text = (__bridge NSString*)ABRecordCopyCompositeName(person);
        //}
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无效手机号码"
                                                            message:@"请选择正确手机号"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

// Called after the user has pressed cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

// Deprecated, use predicateForSelectionOfPerson and/or -peoplePickerNavigationController:didSelectPerson: instead.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

// Deprecated, use predicateForSelectionOfProperty and/or -peoplePickerNavigationController:didSelectPerson:property:identifier: instead.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone, identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    CSLog(@"Select -> %@", phoneNO);
    
    BOOL continueAction = YES;
    if ([phoneNO isValidMobile]) {
        self.fieldPhone.text = phoneNO;
        //if ([self.fieldName.text trim].length == 0) {
        self.fieldName.text = (__bridge NSString*)ABRecordCopyCompositeName(person);
        //}
        
        continueAction = NO;
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无效手机号码"
                                                            message:@"请选择正确手机号"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        continueAction = NO;
    }
    
    return continueAction;
}

@end

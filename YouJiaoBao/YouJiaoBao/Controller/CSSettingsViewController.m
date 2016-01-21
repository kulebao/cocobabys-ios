//
//  CSSettingsViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSSettingsViewController.h"
#import "AHAlertView.h"
#import "CSEngine.h"
#import "CSHttpClient.h"
#import "CSAppDelegate.h"
#import "CSProfileHeaderViewController.h"
#import "CSTextFieldDelegate.h"
#import "EntityChildInfoHelper.h"
#import "UIImage+CSKit.h"
#import "EntityLoginInfoHelper.h"
#import <RongIMKit/RongIMKit.h>
#import "KxMenu.h"

enum {
    // 昵称长度
    kKuleNickMaxLength = 12,
};

@interface CSSettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CSTextFieldDelegate* _nickFieldDelegate;
    UIImagePickerController* _imgPicker;
}

- (IBAction)onBtnLogoutClicked:(id)sender;
- (IBAction)onBtnCheckUpdatesClicked:(id)sender;
- (IBAction)onBtnFeedbackClicked:(id)sender;

@property (nonatomic, weak) CSProfileHeaderViewController* profileHeaderViewCtrl;

@end

@implementation CSSettingsViewController

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
    //[self customizeBackBarItem];
    _nickFieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    _nickFieldDelegate.maxLength = kKuleNickMaxLength;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.settings.profileHeader"]) {
        CSProfileHeaderViewController* profileHeader = segue.destinationViewController;
        profileHeader.delegate = self;
        profileHeader.moreDetails = YES;
        self.profileHeaderViewCtrl = profileHeader;
    }
}

- (IBAction)onBtnLogoutClicked:(id)sender {
    NSString *title = @"提示";
	NSString *message = @"确定要退出登录？";
	
	AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:@"取消" block:^{
	}];
    
	[alert addButtonWithTitle:@"确定" block:^{
        [self performSelector:@selector(doLogout) withObject:nil];
	}];
    
	[alert show];
}

- (IBAction)onBtnCheckUpdatesClicked:(id)sender {
    [self doCheckUpdates];
}

- (IBAction)onBtnFeedbackClicked:(id)sender {
    // Feedback
    RCPublicServiceChatViewController *conversationVC = [[RCPublicServiceChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_APPSERVICE;
    conversationVC.targetId = COCOBABYS_IM_SERVICE_ID;
    conversationVC.userName = nil;
    conversationVC.title = @"客服";
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (void)doLogout {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLogoutSuccess object:nil userInfo:nil];
}

- (void)doCheckUpdates {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSInteger resultCount = [[dataJson valueForKeyNotNull:@"resultCount"] integerValue];
        NSArray* results = [dataJson valueForKeyNotNull:@"results"];
        
        if (resultCount > 1) {
            NSDictionary* rightDic = [results firstObject];
            //获取appstore最新的版本号
            NSString *newVersion = [rightDic objectForKey:@"version"];
            //获取应用程序的地址
            NSString *newURL = [rightDic objectForKey:@"trackViewUrl"];
            NSDictionary *localDic =[[NSBundle mainBundle] infoDictionary];
            NSString *localVersion =[localDic objectForKey:@"CFBundleShortVersionString"];
            if ([localVersion isEqualToString:newVersion]) {
                [gApp alert:@"没有更新"];
            }
            else {
                NSString *title = @"新版本";
                NSString *message = @"发现新版本，是否前去更新？";
                AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
                
                [alert setCancelButtonTitle:@"取消" block:^{
                }];
                
                [alert addButtonWithTitle:@"确定" block:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newURL]];
                }];
                
                [alert show];
            }
        }
        else {
            CSLog(@"没有应用信息。");
            [gApp alert:@"没有更新"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
//        [gApp alert:[error localizedDescription]];
        [gApp alert:@"暂时无法获取版本信息"];
    };
    
    [gApp waitingAlert:@"正在检查更新..."];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    [http opCheckUpdates:kAppleID success:sucessHandler failure:failureHandler];
}

#pragma mark - CSProfileHeaderViewControllerDelegate
- (void)profileHeaderViewControllerWillUpdateProfile:(CSProfileHeaderViewController*)ctrl {
    KxMenuItem* item1 = [KxMenuItem menuItem:@"修改昵称"
                                       image:nil
                                      target:self
                                      action:@selector(doChangeProfileNick)];
    
    KxMenuItem* item2 = [KxMenuItem menuItem:@"从相机拍摄头像"
                                       image:nil
                                      target:self
                                      action:@selector(doChangePortraitFromCamera)];
    
    KxMenuItem* item3 = [KxMenuItem menuItem:@"从相册选择头像"
                                       image:nil
                                      target:self
                                      action:@selector(doChangePortraitFromPhoto)];
    
    [KxMenu setTintColor:[UIColor colorWithRed:0.129f green:0.565f blue:0.839f alpha:1.0f]];
    
    [KxMenu showMenuInView:self.view
                  fromRect:[self.view convertRect:ctrl.btnAvatar.frame fromView:ctrl.view]
                 menuItems:@[item1, item2, item3]];
}

#pragma mark - 
- (void)doChangeProfileNick {
    NSString *title = @"请输入新昵称";
    NSString *message = @"";
    
    CSEngine* engine = [CSEngine sharedInstance];
    
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    alert.alertViewStyle = AHAlertViewStylePlainTextInput;
    
    UITextField* field = [alert textFieldAtIndex:0];
    field.placeholder = @"请输入新昵称";
    field.text = engine.loginInfo.name;
    
    field.keyboardAppearance = UIKeyboardAppearanceDefault;
    field.background = [[UIImage imageNamed:@"input-bg-0.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 10)];
    field.borderStyle = UITextBorderStyleBezel;
    field.backgroundColor = [UIColor clearColor];
    field.font = [UIFont systemFontOfSize:14];
    field.delegate = _nickFieldDelegate;
    
    [alert setCancelButtonTitle:@"取消" block:^{
        
    }];
    
    [alert addButtonWithTitle:@"确定" block:^{
        [self doUpdateChildNick:field.text];
    }];
    
    [alert show];
}

- (void)doUpdateChildNick:(NSString*)nick {
    nick = [nick stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    nick = [nick stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    nick = [nick stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    nick = [nick stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (nick.length > 0) {
        CSEngine* engine = [CSEngine sharedInstance];
        CSHttpClient* http = [CSHttpClient sharedInstance];
        
        if (engine.loginInfo) {
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                CSLog(@"success.");
                [gApp alert:@"修改成功"];
                [EntityLoginInfoHelper updateEntity:dataJson];
                [self.profileHeaderViewCtrl reloadData];
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp alert:[error localizedDescription]];
            };
            
            [gApp waitingAlert:@"修改昵称中，请稍候"];
            [http opUpdateProfile:@{@"name": nick}
                         ofSender:engine.loginInfo
                          success:sucessHandler
                          failure:failureHandler];
        }
        else {
            [gApp alert:@"未登录。"];
        }
    }
    else {
        [gApp alert:@"昵称不能为空"];
    }
}

- (void)doUpdateChildPortrait:(NSString*)portrait withImage:(UIImage*)img {
    if (portrait.length > 0) {
        CSEngine* engine = [CSEngine sharedInstance];
        CSHttpClient* http = [CSHttpClient sharedInstance];
        if (engine.loginInfo) {
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                CSLog(@"success.");
                [gApp alert:@"修改成功"];
                [EntityLoginInfoHelper updateEntity:dataJson];
                [self.profileHeaderViewCtrl reloadData];
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp alert:[error localizedDescription]];
            };
            
            [gApp waitingAlert:@"修改头像中，请稍候"];
            [http opUpdateProfile:@{@"portrait": portrait}
                         ofSender:engine.loginInfo
                          success:sucessHandler
                          failure:failureHandler];
        }
        else {
        }
    }
    else {
        [gApp alert:@"头像不存在"];
    }
}

- (void)doChangePortraitFromPhoto {
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPicker.allowsEditing = YES;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
}

- (void)doChangePortraitFromCamera {
#if TARGET_IPHONE_SIMULATOR
#else
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPicker.allowsEditing = YES;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
#endif
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* img = info[UIImagePickerControllerEditedImage];
    NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
    
    CSEngine* engine = [CSEngine sharedInstance];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSString* imgFileName = [NSString stringWithFormat:@"employee_photo/%@/%@/%@_%@.jpg",
                             engine.loginInfo.schoolId,
                             engine.loginInfo.uid,
                             engine.loginInfo.loginName,
                             @(timestamp)];
    
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* name = [dataJson valueForKeyNotNull:@"name"];
        NSString* portrait = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, name];
        //self.imgChildPortrait.image = img;
        UIImage* cropImg = [img imageByScalingAndCroppingForSize:CGSizeMake(256, 256)];
        [self doUpdateChildPortrait:portrait withImage:cropImg];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传头像中"];
    
    [http opUploadToQiniu:imgData
                  withKey:imgFileName
                 withMime:@"image/jpeg"
                  success:sucessHandler
                  failure:failureHandler];
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (picker == _imgPicker) {
                                       _imgPicker = nil;
                                   }
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    if (picker == _imgPicker) {
        _imgPicker = nil;
    }
}

@end

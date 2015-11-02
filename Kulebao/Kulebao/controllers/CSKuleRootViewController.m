//
//  CSKuleRootViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleRootViewController.h"
#import "CSAppDelegate.h"
#import "BPush.h"

@interface CSKuleRootViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoading;

@end

@implementation CSKuleRootViewController

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
//    if (IS_IPHONE5) {
//        self.imgBg.image = [UIImage imageNamed:@"Default-568h.png"];
//    }
//    else {
//        self.imgBg.image = [UIImage imageNamed:@"Default.png"];
//    }
    
    self.indicatorLoading.hidesWhenStopped = YES;
    
    if (gApp.engine.preferences.loginInfo) {
        gApp.engine.loginInfo = gApp.engine.preferences.loginInfo;
        [self doReceiveBindInfo];
    }
    else {
        [gApp gotoLoginProcess];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doReceiveBindInfo {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        CSLog(@"doReceiveBindInfo error_code=%ld", (long)bindInfo.errorCode);
        if (bindInfo.errorCode == 0) {
            gApp.engine.loginInfo.schoolId = bindInfo.schoolId;
            gApp.engine.loginInfo.accessToken = bindInfo.accessToken;
            gApp.engine.loginInfo.accountName = bindInfo.accountName;
            gApp.engine.loginInfo.username = bindInfo.username;
            gApp.engine.loginInfo.schoolName = bindInfo.schoolName;
            gApp.engine.loginInfo.memberStatus = bindInfo.memberStatus;
            
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            
            [gApp gotoMainProcess];
            [gApp hideAlert];
        }
        else if (bindInfo.errorCode == 1) {
            [gApp logout];
            [gApp alert:@"账号绑定失败，请重新登录。"];
        }
        else if (bindInfo.errorCode == 2) {
            [gApp logout];
            [gApp alert:@"账号未激活或已过期，请联系幼儿园处理，谢谢。"];
        }
        else if (bindInfo.errorCode == 3) {
            [gApp logout];
            [gApp alert:@"该手机号已经在其他手机上登录，为了您账号的安全，请修改密码后再重新登录。"];
        }
        else {
            [gApp logout];
            [gApp alert:@"账号绑定失败，请重新登录。"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp logout];
        [gApp alert:error.localizedDescription];
    };
    
    [gApp waitingAlert:@"获取绑定信息..."];
    [gApp.engine reqReceiveBindInfo:gApp.engine.loginInfo.accountName
                            success:sucessHandler
                            failure:failureHandler];
}

@end

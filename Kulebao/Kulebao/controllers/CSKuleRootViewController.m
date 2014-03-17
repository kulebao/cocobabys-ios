//
//  CSKuleRootViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleRootViewController.h"
#include "CSAppDelegate.h"

@interface CSKuleRootViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;

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
    if (IS_IPHONE5) {
        self.imgBg.image = [UIImage imageNamed:@"Default-568h.png"];
    }
    else {
        self.imgBg.image = [UIImage imageNamed:@"Default.png"];
    }
    
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
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        
        if (bindInfo.errorCode == 0) {
            gApp.engine.bindInfo = bindInfo;
            gApp.engine.loginInfo.schoolId = bindInfo.schoolId;
            gApp.engine.preferences.loginInfo = gApp.engine.loginInfo;
            
            [gApp gotoMainProcess];
            //[gApp alert:@"登录成功"];
            [gApp hideAlert];
        }
        else {
            CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
            [gApp hideAlert];
        }
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    [gApp waitingAlert:@"获取绑定信息..."];
    [gApp.engine reqReceiveBindInfo:gApp.engine.loginInfo.accountName
                            success:sucessHandler
                            failure:failureHandler];
}

@end

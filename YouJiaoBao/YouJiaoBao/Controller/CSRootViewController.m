//
//  CSRootViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-5.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSRootViewController.h"
#import "CSEngine.h"
#import "CSHttpClient.h"

#import "CSMainViewController.h"
#import "CSLoginViewController.h"
#import "CBSessionDataModel.h"

#import <RongIMKit/RongIMKit.h>
#import <Bugly/Bugly.h>

@interface CSRootViewController () <UINavigationControllerDelegate>

@end

@implementation CSRootViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegate =self;
    self.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccess:) name:kNotiLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogoutSuccess:) name:kNotiLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnauthorized:) name:kNotiUnauthorized object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginView:) name:kNotiShowLogin object:nil];
    
    [self autoLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.root.login"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"segue.root.main"]) {
        
    }
}

- (void)checkLocalData {
//    NSFetchedResultsController* frCtrl = [EntityLoginInfoHelper frRecentLoginUser];
//    NSError* error = nil;
//    BOOL ok = [frCtrl performFetch:&error];
//    if (ok && frCtrl.fetchedObjects.count > 0) {
//        [[CSEngine sharedInstance] onLogin:frCtrl.fetchedObjects.lastObject];
//        [self showMainView];
//    }
//    else {
//        [self showLoginView];
//    }
}

- (void)autoLogin {
    ModelAccount* account = [[CSEngine sharedInstance] decryptAccount];
    if ([account isValid]) {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        
        id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            CBLoginInfo* loginInfo = [CBLoginInfo instanceWithDictionary:responseObject];
            if (loginInfo != nil) {
                [Bugly setUserValue:loginInfo.login_name forKey:@"cb_user_name"];
                [Bugly setUserValue:loginInfo.phone forKey:@"cb_user_phone"];
                [Bugly setUserValue:loginInfo.school_id.stringValue forKey:@"cb_user_school_id"];
#if COCOBABYS_USE_ENV_PROD
                [Bugly setUserValue:@"prod" forKey:@"cb_env"];
#else
                [Bugly setUserValue:@"stage" forKey:@"cb_env"];
#endif
                
                CBSessionDataModel* session = [CBSessionDataModel session:loginInfo.phone];
                session.loginInfo = loginInfo;
                [session updateSchoolConfig:loginInfo.school_id.integerValue];
                
                if (loginInfo.im_token) {
                    // 快速集成第二步，连接融云服务器
                    [[RCIM sharedRCIM] connectWithToken:loginInfo.im_token.token
                                                success:^(NSString *userId) {
                                                    // Connect 成功
                                                    CSLog(@"[RCIM] connect success.");
                                                } error:^(RCConnectErrorCode status) {
                                                    // Connect 失败
                                                    CSLog(@"[RCIM] connect error.");
                                                } tokenIncorrect:^() {
                                                    // Token 失效的状态处理
                                                    CSLog(@"[RCIM] connect tokenIncorrect.");
                                                }];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLoginSuccess object:loginInfo userInfo:nil];
            }
            else {
                [self showLoginView];
            }
        };
        
        id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showLoginView];
        };
        
        [http opLoginWithUsername:account.username
                         password:account.password
                          success:success
                          failure:failure];
    }
    else {
        [self showLoginView];
    }
}

- (void)showLoginView {
    //[self performSegueWithIdentifier:@"segue.root.login" sender:nil];
    CSLoginViewController* ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CSLoginViewController"];
    [self setViewControllers:@[ctrl] animated:YES];
    [self setNavigationBarHidden:NO animated:YES];
}

- (void)showMainView {
    //[self performSegueWithIdentifier:@"segue.root.main" sender:nil];
    CSMainViewController* ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CSMainViewController"];
    [self setViewControllers:@[ctrl] animated:YES];
    [self setNavigationBarHidden:NO animated:YES];
}

- (void)onLoginSuccess:(NSNotification*)noti {
    [self showMainView];
}

- (void)onLogoutSuccess:(NSNotification*)noti {
    [[CSEngine sharedInstance] clearAccount];
    [self showLoginView];
}

- (void)onUnauthorized:(NSNotification*)noti {
    CSLog(@"Unauthorized Error : %@", noti.object);
    [self showLoginView];
}

- (void)onLoginView:(NSNotification*)noti {
    [self showLoginView];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:self]) {
        [navigationController setNavigationBarHidden:YES animated:animated];
    }
    else if ([viewController isKindOfClass:[CSMainViewController class]]) {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
    else if ([viewController isKindOfClass:[CSLoginViewController class]]) {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:self]) {
        [navigationController setNavigationBarHidden:YES animated:animated];
    }
    else if ([viewController isKindOfClass:[CSMainViewController class]]) {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
    else if ([viewController isKindOfClass:[CSLoginViewController class]]) {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
}

@end

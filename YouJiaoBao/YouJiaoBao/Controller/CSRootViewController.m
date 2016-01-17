//
//  CSRootViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-5.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSRootViewController.h"
#import "CSEngine.h"
#import "EntityLoginInfoHelper.h"
#import "CSHttpClient.h"

#import "CSMainViewController.h"
#import "CSLoginViewController.h"

#import <RongIMKit/RongIMKit.h>

@interface CSRootViewController () <UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;

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
    self.navigationController.delegate =self;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"v2-head.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    if (!IS_IPHONE4) {
        self.imgBg.image = [UIImage imageNamed:@"v2-启动界面.png"];
    }
    else {
        self.imgBg.image = [UIImage imageNamed:@"v2-启动界面.png"];
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)checkLocalData {
    NSFetchedResultsController* frCtrl = [EntityLoginInfoHelper frRecentLoginUser];
    NSError* error = nil;
    BOOL ok = [frCtrl performFetch:&error];
    if (ok && frCtrl.fetchedObjects.count > 0) {
        [[CSEngine sharedInstance] onLogin:frCtrl.fetchedObjects.lastObject];
        [self showMainView];
    }
    else {
        [self showLoginView];
    }
}

- (void)autoLogin {
    ModelAccount* account = [[CSEngine sharedInstance] decryptAccount];
    if ([account isValid]) {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        
        id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            EntityLoginInfo* loginInfo = [EntityLoginInfoHelper updateEntity:responseObject];
            if (loginInfo != nil) {
                if (loginInfo.im_token) {
                    // 快速集成第二步，连接融云服务器
                    [[RCIM sharedRCIM] connectWithToken:loginInfo.im_token
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
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self performSegueWithIdentifier:@"segue.root.login" sender:nil];
}

- (void)showMainView {
    [self performSegueWithIdentifier:@"segue.root.main" sender:nil];
}

- (void)onLoginSuccess:(NSNotification*)noti {
    [[CSEngine sharedInstance] onLogin:noti.object];
    [self showMainView];
}

- (void)onLogoutSuccess:(NSNotification*)noti {
    [[CSEngine sharedInstance] clearAccount];
    [self showLoginView];
}

- (void)onUnauthorized:(NSNotification*)noti {
    CSLog(@"Unauthorized Error : %@", noti.object);
    [[CSEngine sharedInstance] onLogin:nil];
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

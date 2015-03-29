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

@interface CSRootViewController ()
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE5) {
        self.imgBg.image = [UIImage imageNamed:@"Default-568h.png"];
    }
    else {
        self.imgBg.image = [UIImage imageNamed:@"Default.png"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccess:) name:kNotiLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogoutSuccess:) name:kNotiLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnauthorized:) name:kNotiUnauthorized object:nil];
    
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

@end

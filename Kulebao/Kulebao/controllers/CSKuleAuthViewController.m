//
//  CSKuleAuthViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleAuthViewController.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"
#import "CSKuleLoginViewController.h"
#import "CSAppDelegate.h"
#import "CSKuleVerifyMobileViewController.h"

@interface CSKuleAuthViewController () <EAIntroDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labNotice;
@property (weak, nonatomic) IBOutlet UITextField *fieldMobile;
@property (weak, nonatomic) IBOutlet UIButton *btnDevSetting;
@property (weak, nonatomic) IBOutlet UILabel *labServerName;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgContentBg;
- (IBAction)onBtnSendClicked:(id)sender;
- (IBAction)onBtnDevSettingClicked:(id)sender;

@end

@implementation CSKuleAuthViewController

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
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.title = @"登录账号";
    
    self.fieldMobile.text = gApp.engine.preferences.defaultUsername;
    
    if(COCOBABYS_DEV_MODEL) {
        self.labServerName.hidden = NO;
        self.btnDevSetting.hidden = NO;
        
        NSDictionary* serverInfo = [[CSKulePreferences defaultPreferences] getServerSettings];
        self.labServerName.text = serverInfo[@"name"];
    }
    else {
        self.labServerName.hidden = YES;
        self.btnDevSetting.hidden = YES;
    }
    
    self.imgContentBg.image = [[UIImage imageNamed:@"v2-input_login_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    [self showIntroViewsIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - UI Actions
- (IBAction)onBtnSendClicked:(id)sender {
    [self.fieldMobile resignFirstResponder];
    [self doAuth];
}

- (IBAction)onBtnDevSettingClicked:(id)sender {
}

- (void)doAuth {
    NSString* mobile = self.fieldMobile.text;
    if ([mobile isValidMobile]) {
        gApp.engine.preferences.defaultUsername = mobile;
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            /*
             {
             "check_phone_result" : "1102"
             }
             */
            NSInteger check_phone_result = [[dataJson valueForKeyNotNull:@"check_phone_result"] integerValue];
            
            switch (check_phone_result) {
                case PHONE_NUM_IS_FIRST_USE:
//                {
//                    [gApp hideAlert];
//                    CSLog(@"Server says it's inactive: %@", mobile);
//                    [self performSegueWithIdentifier:@"segue.verifymobile" sender:nil];
//                }
//                    break;
                case PHONE_NUM_IS_ALREADY_BIND:
                {
                    [gApp hideAlert];
                    
                    NSDate* lastLoginDate = [gApp.engine.preferences.historyAccounts objectForKey:mobile];
                    if (lastLoginDate) {
                        [self performSegueWithIdentifier:@"segue.login" sender:nil];
                    }
                    else {
                        CSLog(@"first time to login using account: %@", mobile);
                        [self performSegueWithIdentifier:@"segue.verifymobile" sender:nil];
                    }
                }
                    break;
                    
                case PHONE_NUM_IS_INVALID:
                {
                    [gApp alert:@"账号未激活或已过期，请联系幼儿园处理，谢谢。"
                      withTitle:@"提示"];
                    
                }
                    break;
                default:
                {
                    [gApp alert:@"账号未激活或已过期，请联系幼儿园处理，谢谢。"
                      withTitle:@"提示"];
                }
                    break;
            }
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp waitingAlert:@"正在校验手机号码，请稍候..."];
        [gApp.engine reqCheckPhoneNum:mobile
                              success:sucessHandler
                              failure:failureHandler];
    }
    else if (mobile.length > 0) {
        [gApp alert:@"无效手机号码，请检查后重新输入，谢谢。"];
    }
    else {
        [gApp alert:@"请输入手机号码"];
    }
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.login"]) {
        CSKuleLoginViewController* loginCtrl = segue.destinationViewController;
        loginCtrl.mobile = self.fieldMobile.text;
    }
    else if ([segue.identifier isEqualToString:@"segue.verifymobile"]) {
        CSKuleVerifyMobileViewController* ctrl = segue.destinationViewController;
        ctrl.mobile = self.fieldMobile.text;
        ctrl.delegate = self;
    }
}

#pragma mark - CSKuleVerifyMobileViewControllerDelegate
- (void)verifyMobileViewControllerDidFinished:(CSKuleVerifyMobileViewController*)ctrl {
    [gApp alert:@"绑定手机成功。"];
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"segue.login" sender:nil];
}

#pragma mark - Private
- (void)showIntroViewsIfNeeded {
    if (!gApp.engine.preferences.guideShown) {
        [self showIntroViews];
    }
    else {
    }
}

-(void)showIntroViews {
    //float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSArray* introImageNames = @[@"guide-1.png", @"guide-2.png", @"guide-3.png", @"guide-4.png"];
    if (!IS_IPHONE4) {
        introImageNames = @[@"guide-1-568h.png", @"guide-2-568h.png", @"guide-3-568h.png", @"guide-4-568h.png"];
    }
    
    NSMutableArray* introPages = [NSMutableArray array];
    for (NSString* imageName in introImageNames) {
        EAIntroPage* page = [EAIntroPage page];
        UIImageView* imageV = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageV.image = [UIImage imageNamed:imageName];
        page.customView = imageV;
        [introPages addObject:page];
    }
    
    UIButton* skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setBackgroundImage:[UIImage imageNamed:@"btn-start.png"] forState:UIControlStateNormal];
    [skipButton setBackgroundImage:[UIImage imageNamed:@"btn-start-pressed.png"] forState:UIControlStateHighlighted];
    
    CGSize viewSize = self.view.bounds.size;
    skipButton.frame = CGRectMake((viewSize.width-126)/2, viewSize.height-90, 126, 27);
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds
                                                   andPages:introPages];
    intro.skipButton = skipButton;
    intro.backgroundColor = [UIColor whiteColor];
    intro.scrollView.bounces = NO;
    intro.swipeToExit = NO;
    intro.easeOutCrossDisolves = NO;
    intro.showSkipButtonOnlyOnLastPage = YES;
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0];
}

#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
    gApp.engine.preferences.guideShown = YES;
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

@end

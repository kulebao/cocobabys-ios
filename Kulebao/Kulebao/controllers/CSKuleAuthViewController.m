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

@interface CSKuleAuthViewController () <EAIntroDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labNotice;
@property (weak, nonatomic) IBOutlet UITextField *fieldMobile;
- (IBAction)onBtnSendClicked:(id)sender;

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
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UI Actions
- (IBAction)onBtnSendClicked:(id)sender {
    [self.fieldMobile resignFirstResponder];
    //[self performSegueWithIdentifier:@"segue.login" sender:nil];
    [self doAuth];
}

- (void)doAuth {
    NSString* mobile = self.fieldMobile.text;
    if (mobile.length > 0) {
        gApp.engine.preferences.defaultUsername = mobile;
        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            /*
             {
             "check_phone_result" : "1102"
             }
             */
            NSInteger check_phone_result = [[dataJson valueForKeyNotNull:@"check_phone_result"] integerValue];
            
            switch (check_phone_result) {
                case PHONE_NUM_IS_ALREADY_BIND:
                case PHONE_NUM_IS_FIRST_USE:
                {
                    [gApp hideAlert];
                    [self performSegueWithIdentifier:@"segue.login" sender:nil];
                }
                    break;
                case PHONE_NUM_IS_INVALID:
                {
                    [gApp alert:@"手机号码没有注册，请确认输入是否正确或联系幼儿园处理，谢谢！"
                      withTitle:@"提示"];
                    
                }
                    break;
                default:
                {
                    [gApp hideAlert];
                }
                    break;
            }
        };
        
        FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
            CSLog(@"failure:%@", error);
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp waitingAlert:@"正在校验手机号码，请稍候..."];
        [gApp.engine reqCheckPhoneNum:mobile
                              success:sucessHandler
                              failure:failureHandler];
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
    if (IS_IPHONE5) {
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
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds
                                                   andPages:introPages];
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

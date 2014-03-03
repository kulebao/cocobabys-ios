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
    
    [self showIntroViewsIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Actions
- (IBAction)onBtnSendClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.login" sender:nil];
}

#pragma mark - Private
- (void)showIntroViewsIfNeeded {
    NSUserDefaults* config = [NSUserDefaults standardUserDefaults];
    [config removeObjectForKey:@"com.cocobabys.Kulebao.runTime"];
    
    NSNumber* runTime = [config objectForKey:@"com.cocobabys.Kulebao.runTime"];
    NSInteger runTimeInt = [runTime integerValue];
    if (runTimeInt == 0) {
        [self showIntroViews];
        //[self performSegueWithIdentifier:@"segue.auth" sender:nil];
    }
    else {
        //[self performSegueWithIdentifier:@"segue.main" sender:nil];
    }
    [config setObject:@(runTimeInt+1) forKey:@"com.cocobabys.Kulebao.runTime"];
    [config synchronize];
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
    
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

@end

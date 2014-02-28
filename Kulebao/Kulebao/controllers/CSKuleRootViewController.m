//
//  CSKuleRootViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleRootViewController.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"

@interface CSKuleRootViewController () <EAIntroDelegate>
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
    
//    UIImage* bg = [UIImage imageNamed:@"app-bg-type1.png"];
//    self.imgBg.image = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(200, 1, 200, 1)];
    
    [self showIntroViewsIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showIntroViewsIfNeeded {
    //[NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults* config = [NSUserDefaults standardUserDefaults];
    NSNumber* runTime = [config objectForKey:@"com.cocobabys.Kulebao.runTime"];
    NSInteger runTimeInt = [runTime integerValue];
    if (runTimeInt == 0) {
        [self showIntroViews];
        [self performSegueWithIdentifier:@"segue.auth" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"segue.main" sender:nil];
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
    [intro showInView:self.navigationController.view animateDuration:0.3];
}

#pragma mark - - (void)introDidFinish:(EAIntroView *)introView;
- (void)introDidFinish:(EAIntroView *)introView {
   
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}


@end

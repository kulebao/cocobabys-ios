//
//  CSKuleAboutSchoolViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleAboutSchoolViewController.h"
#import "UIImageView+WebCache.h"
#import "CSAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface CSKuleAboutSchoolViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CSKuleAboutSchoolViewController
@synthesize schoolInfo = _schoolInfo;

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
    [self customizeBackBarItem];
    
    [self reloadSchoolInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Setters
- (void)setSchoolInfo:(CSKuleSchoolInfo *)schoolInfo {
    _schoolInfo = schoolInfo;

    if ([self isViewLoaded]) {
        [self reloadSchoolInfo];
    }
}

#pragma mark - UI Actions
- (void)onBtnCallPhoneClicked:(id)sender {
    BOOL ok = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", _schoolInfo.phone]]];
    if (!ok && _schoolInfo.phone) {
        [gApp alert:@"本设备不支持拨打电话"];
    }
}

#pragma mark - Private
- (void)reloadSchoolInfo {
    for (UIView* subV in self.scrollView.subviews) {
        [subV removeFromSuperview];
    }
    
    if (_schoolInfo) {
        //CGFloat xx = 0.0;
        CGFloat yy = 0.0;
        CGFloat spaceH = 10.0;
        
        const CGFloat kWidth = self.scrollView.bounds.size.width;
        //const CGFloat kHeight = self.scrollView.bounds.size.height;
        
        if (_schoolInfo.schoolLogoUrl.length > 0) {
            const CGFloat kSchoolLogoWidth = kWidth - 20;
            const CGFloat kSchoolLogoHeight = kSchoolLogoWidth * 3 / 4;
            
            UIImageView* schoolLogo = [[UIImageView alloc] initWithFrame:CGRectMake((kWidth - kSchoolLogoWidth)/2.0, yy, kSchoolLogoWidth, kSchoolLogoHeight)];
            schoolLogo.contentMode = UIViewContentModeScaleAspectFit;
            schoolLogo.clipsToBounds = YES;
            
            [schoolLogo sd_setImageWithURL:[gApp.engine urlFromPath:_schoolInfo.schoolLogoUrl]];
            [self.scrollView addSubview:schoolLogo];
            yy += kSchoolLogoHeight;
        }
        
        if (_schoolInfo.desc.length > 0) {
            const CGFloat kSchoolDescWidth = kWidth - 20;
            UITextView* descText = [[UITextView alloc] initWithFrame:CGRectMake((kWidth - kSchoolDescWidth)/2.0, yy, kSchoolDescWidth, 99999)];
            descText.backgroundColor = [UIColor clearColor];
            descText.font = [UIFont systemFontOfSize:14.0];
            descText.text = _schoolInfo.desc;
            CGSize sz = [descText sizeThatFits:CGSizeMake(kSchoolDescWidth, 99999)];
            descText.frame = CGRectMake((kWidth - kSchoolDescWidth)/2.0, yy, sz.width, sz.height);
            descText.userInteractionEnabled = NO;
            [self.scrollView addSubview:descText];
            yy += sz.height;
        }
        
        if (_schoolInfo.phone.length > 0) {
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake(10, yy, kWidth-10*2, 1)];
            line.backgroundColor = UIColorRGB(0xCC, 0x66, 0x33);
            [_scrollView addSubview:line];
            yy += 5;
            
            UIImage* imgBtnBg = [UIImage imageNamed:@"btn-type1.png"];
            UIImage* imgBtnBgPress = [UIImage imageNamed:@"btn-type1-pressed.png"];
            UIButton* btnCallPhone = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCallPhone.frame = CGRectMake((kWidth-imgBtnBg.size.width)/2, yy, imgBtnBg.size.width, imgBtnBg.size.height);
            
            [btnCallPhone setBackgroundImage:imgBtnBg forState:UIControlStateNormal];
            [btnCallPhone setBackgroundImage:imgBtnBgPress forState:UIControlStateHighlighted];
            [btnCallPhone addTarget:self action:@selector(onBtnCallPhoneClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btnCallPhone setTitle:@"联系我们" forState:UIControlStateNormal];
            
            [_scrollView addSubview:btnCallPhone];
            yy += btnCallPhone.frame.size.height;
        }
        
        _scrollView.contentSize = CGSizeMake(kWidth, yy+spaceH);
    }
    else {
        _scrollView.contentSize = _scrollView.bounds.size;
    }
}

@end

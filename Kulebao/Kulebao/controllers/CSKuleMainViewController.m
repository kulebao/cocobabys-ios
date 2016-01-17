//
//  CSKuleMainViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleMainViewController.h"
#import "CSAppDelegate.h"
#import "KxMenu.h"
#import "AHAlertView.h"
#import "CSKuleAboutSchoolViewController.h"
#import "ALAlertBanner.h"
#import "JSBadgeView.h"
#import "CSKuleDatePickerViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIImage+CSExtends.h"
#import "UIImageView+WebCache.h"
#import "CSKuleVideoMember.h"
#import "CSKuleCCTVMainTableViewController.h"
#import "CSKuleInterpreter.h"
#import "CSKuleNewsDetailsViewController.h"
#import "CBActivityData.h"
#import "CBContractorData.h"
#import "CBIMChatListViewController.h"

#import "EAIntroPage.h"
#import "EAIntroView.h"

#import "CBIMDataSource.h"
#import "UIActionSheet+BlocksKit.h"

@interface CSKuleMainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, EAIntroDelegate> {
    UIImagePickerController* _imgPicker;
    CSTextFieldDelegate* _nickFieldDelegate;
    NSMutableArray* _badges;
    NSArray* _moduleInfos;
    
    BOOL _actionToCCTV;
}

@property (weak, nonatomic) IBOutlet UILabel *labChildNick;
@property (weak, nonatomic) IBOutlet UIImageView *imgChildPortrait;
@property (weak, nonatomic) IBOutlet UIView *viewChildContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContent;

@property (weak, nonatomic) IBOutlet UIButton *btnClassInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnSchoolInfo;

@property (nonatomic, strong) CSKuleSchoolInfo* schoolInfo;
@property (nonatomic, strong) CSKuleVideoMember* videoMember;
@property (nonatomic, strong) CSKuleVideoMember* defaultVideoMember;

@property (nonatomic, strong) JSBadgeView* badgeCommercial;

@property (nonatomic, strong) UIButton* btnGuideHome;

- (IBAction)onBtnShowChildMenuListClicked:(id)sender;
- (IBAction)onBtnSettingsClicked:(id)sender;
- (IBAction)onBtnSchoolInfoClicked:(id)sender;
- (IBAction)onBtnClassInfoClicked:(id)sender;

@end

@implementation CSKuleMainViewController
@synthesize schoolInfo = _schoolInfo;
@synthesize videoMember = _videoMember;
@synthesize defaultVideoMember = _defaultVideoMember;

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
    self.navigationController.navigationBarHidden = NO;
    
    self.labChildNick.text = nil;
    self.imgChildPortrait.layer.cornerRadius = self.imgChildPortrait.frame.size.width/2;
    self.imgChildPortrait.clipsToBounds = YES;
    self.imgChildPortrait.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imgChildPortrait.layer.borderWidth = 2;
    
    self.btnSchoolInfo.titleLabel.numberOfLines = 2;
    self.btnSchoolInfo.titleLabel.minimumScaleFactor = 0.7;
    self.btnSchoolInfo.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnClassInfo.titleLabel.numberOfLines = 2;
    self.btnClassInfo.titleLabel.minimumScaleFactor = 0.7;
    self.btnClassInfo.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.btnSchoolInfo setTitle:@"学校简介"
                        forState:UIControlStateNormal];
    
    _nickFieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    _nickFieldDelegate.maxLength = kKuleNickMaxLength;
    
    //
    self.badgeCommercial = [[JSBadgeView alloc] initWithParentView:self.btnClassInfo
                                                         alignment:JSBadgeViewAlignmentTopRight];
    self.badgeCommercial.badgeText = @"新";
    self.badgeCommercial.badgePositionAdjustment = CGPointMake(-10, 10);

    //[self setupModules];
    [self doGetSchoolInfo:^{
        [self setupModules];
    }];
    
    [gApp.engine addObserver:self
                  forKeyPath:@"currentRelationship"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfNews"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfRecipe"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfCheckin"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfSchedule"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    /*
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfAssignment"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
     */
    /*
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfChating"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
     */
    
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfAssess"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [gApp.engine addObserver:self
                  forKeyPath:@"pendingNotificationInfo"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [self performSelector:@selector(getRelationshipInfos) withObject:nil afterDelay:0];
    
    [self updateUI:YES];
    

    
    //Guide
    [self showIntroViewsIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [gApp.engine removeObserver:self forKeyPath:@"currentRelationship"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfNews"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfRecipe"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfCheckin"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfSchedule"];
    //[gApp.engine removeObserver:self forKeyPath:@"badgeOfAssignment"];
    //[gApp.engine removeObserver:self forKeyPath:@"badgeOfChating"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfAssess"];
    [gApp.engine removeObserver:self forKeyPath:@"pendingNotificationInfo"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CSLog(@"%@ changed.", keyPath);
    if ((object == gApp.engine) && [keyPath isEqualToString:@"pendingNotificationInfo"]) {
        [self handlePendingNotification];
    }
    else if ((object == gApp.engine) && [keyPath isEqualToString:@"currentRelationship"]) {
        [self updateUI:YES];
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        if (currentChild) {
            if ([gApp.engine.loginInfo.memberStatus isEqualToString:@"free"]) {
                [gApp.engine checkUpdatesOfNews];
                [gApp.engine checkUpdatesOfCheckin];
            }
            else if ([gApp.engine.loginInfo.memberStatus isEqualToString:@"paid"]) {
                [gApp.engine checkUpdatesOfNews];
                [gApp.engine checkUpdatesOfRecipe];
                [gApp.engine checkUpdatesOfCheckin];
                [gApp.engine checkUpdatesOfSchedule];
                [gApp.engine checkUpdatesOfAssignment];
                [gApp.engine checkUpdatesOfChating];
                [gApp.engine checkUpdatesOfAssess];
                
                [self performSelector:@selector(reloadVideoMember) withObject:nil afterDelay:0];
            }
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfNews"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleNews];
        if (badgeView && gApp.engine.badgeOfNews > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的校园公告"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfRecipe"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleRecipe];
        if (badgeView && gApp.engine.badgeOfRecipe > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的每周食谱"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfCheckin"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleCheckin];
        if (badgeView && gApp.engine.badgeOfCheckin > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的接送消息"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfSchedule"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleSchedule];
        if (badgeView && gApp.engine.badgeOfSchedule > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的课程表"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfAssignment"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleAssignment];
        if (badgeView && gApp.engine.badgeOfAssignment > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的亲子作业"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfChating"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleChating];
        if (badgeView && gApp.engine.badgeOfChating > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的家园互动"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfAssess"]) {
        JSBadgeView* badgeView = [self badgeViewForModule:kKuleModuleAssess];
        if (badgeView && gApp.engine.badgeOfAssess > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的在园表现"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else {
        CSLog(@"UNKNOWN.");
    }
}

- (JSBadgeView*)badgeViewForModule:(NSUInteger)moduleType {
    JSBadgeView* badgeView = nil;
    for (JSBadgeView* v in _badges) {
        if (v.tag == moduleType) {
            badgeView = v;
            break;
        }
    }
    
    return badgeView;
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [_scrollContent flashScrollIndicators];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!gApp.engine.preferences.enabledCommercial) {
        [self performSelectorInBackground:@selector(reloadContractorItemDataList)
                               withObject:nil];
    }
    else {
        [self updateCommercialStatus];
    }
    
    [self updateUI:YES];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.aboutschool"]) {
        CSKuleAboutSchoolViewController* destCtrl = segue.destinationViewController;
        destCtrl.schoolInfo = _schoolInfo;
    }
    else if ([segue.identifier isEqualToString:@"segue.cctv"]) {
        CSKuleCCTVMainTableViewController* destCtrl = segue.destinationViewController;
        if (self.videoMember.account.length > 0
            && self.videoMember.password.length > 0) {
            destCtrl.videoMember = self.videoMember;
            destCtrl.isTrail = NO;
        }
        else if (self.defaultVideoMember.account.length > 0
                 && self.defaultVideoMember.password.length > 0) {
            destCtrl.videoMember = self.defaultVideoMember;
            destCtrl.isTrail = YES;
            //[gApp alert:@"宝宝所在的幼儿园暂未开通此功能，该实时视频仅供演示，如需要开通，请联系幼儿园。"];
        }
        else {
            
        }
        
        _actionToCCTV = NO;
    }
}

#pragma mark - UI
- (void)updateCommercialStatus {
    [self updateUI:NO];
}

- (void)setupModules {
    if (_schoolInfo && [_schoolInfo hasProperty:@"hideVideo"]) {
        _moduleInfos = @[
                         @[@"校园公告", @"v2-校园公告.png", @(kKuleModuleNews)],
                         @[@"课程表",   @"v2-课程表.png", @(kKuleModuleSchedule)],
                         @[@"每周食谱", @"v2-每周食谱.png", @(kKuleModuleRecipe)],
                         
                         @[@"家园互动", @"v2-家园互动.png", @(kKuleModuleChating)],
                         @[@"成长经历", @"v2-成长经历.png", @(kKuleModuleHistory)],
                         @[@"接送消息", @"v2-接送消息.png", @(kKuleModuleCheckin)],
                         
                         @[@"在园表现",  @"v2-在园表现.png", @(kKuleModuleAssess)],
                         @[@"校车接送",   @"v2-校车接送.png", @(kKuleModuleBus)],
                         //@[@"看宝宝",   @"v2-看宝宝.png", @(kKuleModuleCCTV)]
                         ];
    }
    else {
        _moduleInfos = @[
                         @[@"校园公告", @"v2-校园公告.png", @(kKuleModuleNews)],
                         @[@"课程表",   @"v2-课程表.png", @(kKuleModuleSchedule)],
                         @[@"每周食谱", @"v2-每周食谱.png", @(kKuleModuleRecipe)],
                         
                         @[@"家园互动", @"v2-家园互动.png", @(kKuleModuleChating)],
                         @[@"成长经历", @"v2-成长经历.png", @(kKuleModuleHistory)],
                         @[@"接送消息", @"v2-接送消息.png", @(kKuleModuleCheckin)],
                         
                         @[@"在园表现",  @"v2-在园表现.png", @(kKuleModuleAssess)],
                         @[@"校车接送",   @"v2-校车接送.png", @(kKuleModuleBus)],
                         @[@"看宝宝",   @"v2-看宝宝.png", @(kKuleModuleCCTV)]
                         ];
    }
    
    _badges = [NSMutableArray arrayWithCapacity:_moduleInfos.count];
    
    const NSInteger kModuleColumns = 3;
    const CGFloat kModuleTopMagin = 15;
    const CGFloat kCellSize = (self.view.bounds.size.width - 50) / kModuleColumns;
    const CGSize kModuleIconSize = CGSizeMake(kCellSize, kCellSize);
    const CGSize kModuleTitleSize = CGSizeMake(kCellSize, 0);
    const CGFloat kModuleRowSpace = kCellSize/8;

    const CGFloat kModuleColumnSpace = (_scrollContent.bounds.size.width - kModuleIconSize.width*kModuleColumns)/(kModuleColumns+1);
    
    CGFloat xx = 0.0;
    CGFloat yy = 0.0;
    NSInteger row = 0;
    NSInteger col = 0;
    
    for (UIView* v in _scrollContent.subviews) {
        [v removeFromSuperview];
    }
    
    for (NSInteger i=0; i<_moduleInfos.count; i++) {
        row = i / kModuleColumns;
        col = i % kModuleColumns;
        xx = kModuleColumnSpace + col * (kModuleIconSize.width+kModuleColumnSpace);
        yy = kModuleTopMagin + row*(kModuleIconSize.height+kModuleTitleSize.height+kModuleRowSpace);
        
        UIButton* btnIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* moduleIconName = _moduleInfos[i][1];
        NSInteger moduleType = [_moduleInfos[i][2] integerValue];
        [btnIcon setBackgroundImage:[UIImage imageNamed:moduleIconName] forState:UIControlStateNormal];
        btnIcon.tag = moduleType;
        btnIcon.frame = CGRectMake(xx, yy, kModuleIconSize.width, kModuleIconSize.height);
        [_scrollContent addSubview:btnIcon];
        [btnIcon addTarget:self action:@selector(onBtnModulesClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        yy += kModuleIconSize.height;
        
#ifdef COCOSBABY_HAS_MODULE_TITLE
        NSString* moduleName = _moduleInfos[i][0];
        UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(xx, yy, kModuleTitleSize.width, kModuleTitleSize.height)];
        labTitle.textColor = UIColorRGB(0xCC, 0x66, 0x33);
        labTitle.font = [UIFont boldSystemFontOfSize:14];
        labTitle.text = moduleName;
        labTitle.textAlignment = NSTextAlignmentCenter;
        labTitle.backgroundColor = [UIColor clearColor];
        [_scrollContent addSubview:labTitle];
#endif
        
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:btnIcon
                                                               alignment:JSBadgeViewAlignmentTopRight];
        badgeView.tag = moduleType;
        badgeView.badgePositionAdjustment = CGPointMake(-5, 5);
        //badgeView.badgeText =[NSString stringWithFormat:@"%d", i];
        [_badges addObject:badgeView];
    }
    
    yy += kModuleTitleSize.height+kModuleRowSpace;
    
    self.scrollContent.contentSize = CGSizeMake(_scrollContent.bounds.size.width, yy);
    self.scrollContent.showsVerticalScrollIndicator = YES;
}

- (void)updateUI:(BOOL)reloadPortrait {
    CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
    NSString* schoolName = [gApp.engine.loginInfo.schoolName trim];
    if ([schoolName length] <=0) {
        schoolName = @"学校简介";
    }
    /*
    [self.btnSchoolInfo setTitle:schoolName
                        forState:UIControlStateNormal];
     */
    
    BOOL enabledCommercial = gApp.engine.preferences.enabledCommercial;
    
    if (childInfo) {
        //CSLog(@"childInfo:%@", childInfo);
        //CSLog(@"parentInfo:%@", gApp.engine.currentRelationship.parent);
        
        NSString* className = [childInfo.className trim];
        if ([className length] <=0) {
            className = @"默认班级";
        }

        NSString* childInfoText = [NSString stringWithFormat:@"%@\r\n%@",
                                   childInfo.displayNick,
                                   childInfo.displayAge];
        
        if (enabledCommercial) {
            childInfoText = [NSString stringWithFormat:@"%@\r\n%@\r\n%@",
                             childInfo.displayNick,
                             childInfo.displayAge,
                             className];
            [self.btnClassInfo setTitle:@"亲子优惠"
                               forState:UIControlStateNormal];
            self.badgeCommercial.hidden = NO;
        }
        else {
            [self.btnClassInfo setTitle:className
                               forState:UIControlStateNormal];
            self.badgeCommercial.hidden = YES;
        }
        
        // 设置行间距
        NSMutableParagraphStyle* ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = 8;
        NSMutableAttributedString* atrText = [[NSMutableAttributedString alloc] initWithString:childInfoText];
        [atrText addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, childInfoText.length)];
        self.labChildNick.attributedText = atrText;
        
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:childInfo.portrait];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/256/h/256"];
        
        SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority |SDWebImageAllowInvalidSSLCertificates;
        
        UIImage* placeholderImage = [UIImage imageNamed:@"default_child_head_icon.png"];
 
        
        if (reloadPortrait) {
            options = options | SDWebImageRefreshCached;
        }
        else {
            if (self.imgChildPortrait.image) {
                placeholderImage = self.imgChildPortrait.image;
            }
        }

        [self.imgChildPortrait  sd_setImageWithURL:qiniuImgUrl
                                  placeholderImage:placeholderImage
                                           options:options];
    }
    else {
        self.labChildNick.text = nil;
        self.imgChildPortrait.image = nil;
        NSString* className = @"默认班级";
        if (enabledCommercial) {
            [self.btnClassInfo setTitle:@"亲子优惠"
                               forState:UIControlStateNormal];
        }
        else {
            [self.btnClassInfo setTitle:className
                               forState:UIControlStateNormal];
        }
        //[gApp alert:@"没有宝宝信息。"];
    }
}

- (void)doChangeChildNick {
    NSString *title = @"设置宝贝昵称";
    NSString *message = [NSString stringWithFormat:@"您最多可以输入%d个字", kKuleNickMaxLength];
    
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    alert.alertViewStyle = AHAlertViewStylePlainTextInput;
    alert.messageTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    
    UITextField* field = [alert textFieldAtIndex:0];
    field.placeholder = @"请输入宝贝昵称";
    field.text = gApp.engine.currentRelationship.child.nick;
    field.keyboardAppearance = UIKeyboardAppearanceDefault;
    //field.background = [[UIImage imageNamed:@"input-bg-0.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 10)];
    //field.borderStyle = UITextBorderStyleBezel;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.backgroundColor = [UIColor clearColor];
    field.font = [UIFont systemFontOfSize:14];
    field.delegate = _nickFieldDelegate;
    
    [alert setCancelButtonTitle:@"取消" block:^{
        
    }];
    
    [alert addButtonWithTitle:@"确定" block:^{
        [self doUpdateChildNick:field.text];
    }];
    
    [alert show];
}

- (void)doChangeChildBirthday {
    CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
    if (childInfo) {
        NSDate* date = [NSDate dateFromString:childInfo.birthday withFormat:@"yyyy-MM-dd"];
        CSKuleDatePickerViewController* ctrl = [[CSKuleDatePickerViewController alloc] initWithNibName:@"CSKuleDatePickerViewController" bundle:nil];
        ctrl.date = date;
        [self presentPopupViewController:ctrl animationType:MJPopupViewAnimationFade dismissed:^{
            CSLog(@"%@", [ctrl.date isoDateString]);
            
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                CSLog(@"success.");
                [gApp alert:@"修改成功"];
                
                CSKuleChildInfo* cc = [CSKuleInterpreter decodeChildInfo:dataJson];
                childInfo.birthday = cc.birthday;
                
                [self updateUI:NO];
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp alert:[error localizedDescription]];
            };
            
            [gApp waitingAlert:@"修改宝宝生日..."];
            CSKuleChildInfo* cp = [childInfo copy];
            cp.birthday = [ctrl.date isoDateString];
            [gApp.engine.httpClient reqUpdateChildInfo:cp
                             inKindergarten:gApp.engine.loginInfo.schoolId
                                    success:sucessHandler
                                    failure:failureHandler];
            
        }];
    }
    else {
        [gApp alert:@"没有宝宝信息。"];
    }
}

- (void)doUpdateChildNick:(NSString*)nick {
    if (nick.length > 0) {
        CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
        if (childInfo) {
            CSKuleChildInfo* cp = [childInfo copy];
            cp.nick = nick;
            
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                CSLog(@"success.");
                [gApp alert:@"修改成功"];
                
                CSKuleChildInfo* cc = [CSKuleInterpreter decodeChildInfo:dataJson];
                childInfo.nick = cc.nick;
                
                [self updateUI:NO];
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp alert:[error localizedDescription]];
            };
            
            [gApp waitingAlert:@"修改宝宝昵称中，请稍候"];
            [gApp.engine.httpClient reqUpdateChildInfo:cp
                             inKindergarten:gApp.engine.loginInfo.schoolId
                                    success:sucessHandler
                                    failure:failureHandler];
        }
        else {
            [gApp alert:@"没有宝宝信息。"];
        }
    }
    else {
        [gApp alert:@"昵称不能为空"];
    }
}

- (void)doUpdateChildPortrait:(NSString*)portrait withImage:(UIImage*)img {
    if (portrait.length > 0) {
        CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
        if (childInfo) {
            CSKuleChildInfo* cp = [childInfo copy];
            cp.portrait = portrait;
            
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                CSLog(@"success.");
                [gApp alert:@"更新成功"];
                
                CSKuleChildInfo* cc = [CSKuleInterpreter decodeChildInfo:dataJson];
                childInfo.portrait = cc.portrait;
                
                self.imgChildPortrait.image = img;
                
                [self updateUI:NO];
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp alert:[error localizedDescription]];
                //[self updateUI:NO];
            };
            
            [gApp waitingAlert:@"更新宝宝头像中"];
            [gApp.engine.httpClient reqUpdateChildInfo:cp
                             inKindergarten:gApp.engine.loginInfo.schoolId
                                    success:sucessHandler
                                    failure:failureHandler];
            
        }
        else {
            [gApp alert:@"没有宝宝信息。"];
        }
    }
    else {
        [gApp alert:@"头像不存在"];
    }
}

- (void)doChangePortraitFromPhoto {
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPicker.allowsEditing = YES;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
}

- (void)doChangePortraitFromCamera {
#if TARGET_IPHONE_SIMULATOR
#else
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPicker.allowsEditing = YES;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
#endif
}

- (void)doChangePortrait {
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet bk_addButtonWithTitle:@"拍照" handler:^{
        [self doChangePortraitFromCamera];
    }];
    
    [sheet bk_addButtonWithTitle:@"从相册选择" handler:^{
        [self doChangePortraitFromPhoto];
    }];
    
    [sheet showInView:self.view];
}

- (void)doGetSchoolInfo:(void(^)())completion {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        id schoolInfoJson = [dataJson valueForKeyNotNull:@"school_info"];
        
        CSKuleSchoolInfo* schoolInfo = nil;
        if (schoolInfoJson) {
            schoolInfo = [CSKuleInterpreter decodeSchoolInfo:schoolInfoJson];
        }
        
        if(schoolInfo) {
            _schoolInfo = schoolInfo;
            //[self performSegueWithIdentifier:@"segue.aboutschool" sender:nil];
            [gApp hideAlert];
            
            if (completion) {
                completion();
            }
        }
        else {
            [gApp alert:@"无学校信息"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"获取信息中..."];
    [gApp.engine.httpClient reqGetSchoolInfoOfKindergarten:gApp.engine.loginInfo.schoolId
                                        success:sucessHandler
                                        failure:failureHandler];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* img = info[UIImagePickerControllerEditedImage];
    NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
    
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSString* imgFileName = [NSString stringWithFormat:@"child_photo/%@/%@/%@_%@.jpg",
                             @(gApp.engine.loginInfo.schoolId),
                             gApp.engine.currentRelationship.child.childId,
                             gApp.engine.currentRelationship.child.childId,
                             @(timestamp)];
    
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* name = [dataJson valueForKeyNotNull:@"name"];
        NSString* portrait = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, name];
        //self.imgChildPortrait.image = img;
        UIImage* cropImg = [img imageByScalingAndCroppingForSize:CGSizeMake(256, 256)];
        [self doUpdateChildPortrait:portrait withImage:cropImg];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传宝宝头像中"];
    [gApp.engine.httpClient reqUploadToQiniu:imgData
                          withKey:imgFileName
                         withMime:@"image/jpeg"
                          success:sucessHandler
                          failure:failureHandler];
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if (picker == _imgPicker) {
                                       _imgPicker = nil;
                                   }
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    if (picker == _imgPicker) {
        _imgPicker = nil;
    }
}

#pragma mark - Segues
- (IBAction)onBtnShowChildMenuListClicked:(id)sender {
    KxMenuItem* item1 = [KxMenuItem menuItem:@"设置宝贝昵称"
                                       image:nil
                                      target:self
                                      action:@selector(doChangeChildNick)];
    
    KxMenuItem* item2 = [KxMenuItem menuItem:@"设置宝贝生日"
                                       image:nil
                                      target:self
                                      action:@selector(doChangeChildBirthday)];
    
//    KxMenuItem* item3 = [KxMenuItem menuItem:@"从相机拍摄头像"
//                                       image:nil
//                                      target:self
//                                      action:@selector(doChangePortraitFromCamera)];
//    
//    KxMenuItem* item4 = [KxMenuItem menuItem:@"从相册选择头像"
//                                       image:nil
//                                      target:self
//                                      action:@selector(doChangePortraitFromPhoto)];
    
    KxMenuItem* item3 = [KxMenuItem menuItem:@"设置宝贝头像"
                                       image:nil
                                      target:self
                                      action:@selector(doChangePortrait)];
    
    //[KxMenu setTintColor:UIColorRGB(0xCC, 0x66, 0x33)];
    [KxMenu setTintColor:[UIColor colorWithRed:0.129f green:0.565f blue:0.839f alpha:1.0f]];
    [KxMenu showMenuInView:self.view
                  fromRect:self.viewChildContainer.frame
                 menuItems:@[item1, item2, item3]];
}

#pragma mark - UI Actions
- (BOOL)checkModuleTypeForMemberStatus:(NSInteger)moduleType {
    BOOL ok = NO;
    if ([gApp.engine.loginInfo.memberStatus isEqualToString:@"free"]) {
        switch (moduleType) {
            case kKuleModuleNews:       // 校园公告
            case kKuleModuleCheckin:    // 接送信息
                ok = YES;
                break;
            case kKuleModuleRecipe:     // 每周食谱
                [gApp alert:@"您想知道宝贝每天的膳食吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleSchedule:    // 课程表
                [gApp alert:@"您想知道宝贝每天的学习内容吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleAssignment:  // 亲子作业
                [gApp alert:@"您想看看老师布置了什么亲子作业吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleChating:     // 家园互动
                [gApp alert:@"您想随时和老师零距离沟通吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleAssess:      // 在园表现
                [gApp alert:@"您想看看老师对宝贝在幼儿园的表现有什么评价吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleHistory:     // 成长经历
                [gApp alert:@"您想记录下宝贝在幼儿园的点点滴滴吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleCCTV:        // 看宝宝
                [gApp alert:@"您想随时看到宝贝在做什么吗？赶快联系幼儿园开通此功能吧！"];
                break;
            case kKuleModuleBus:         // 校车
                [gApp alert:@"您想查看校车的行驶情况吗？赶快联系幼儿园开通此功能吧！"];
                break;
            default:
                ok = NO;
                break;
        }
    }
    else if ([gApp.engine.loginInfo.memberStatus isEqualToString:@"paid"]) {
        ok = YES;
    }
    
    return ok;
}

- (void)onBtnModulesClicked:(UIButton*)sender {
    NSInteger moduleType = sender.tag;
    
    static NSString* segueNames[] = {
        @"segue.newslist",
        @"segue.recipe",
        @"segue.checkin",
        @"segue.schedule",
        @"segue.assignment",
        @"segue.chating",
        @"segue.assess",
        @"segue.history",
        @"segue.cctv",
        @"segue.bus"
    };
    
    if (moduleType < kKuleModuleSize && moduleType < (sizeof(segueNames)/sizeof(NSString*))) {
        if ([self checkModuleTypeForMemberStatus:moduleType]) {
            switch (moduleType) {
                case kKuleModuleNews:
                    gApp.engine.badgeOfNews = 0;
                    break;
                case kKuleModuleRecipe:
                    gApp.engine.badgeOfRecipe = 0;
                    break;
                case kKuleModuleCheckin:
                    gApp.engine.badgeOfCheckin = 0;
                    break;
                case kKuleModuleSchedule:
                    gApp.engine.badgeOfSchedule = 0;
                    break;
                case kKuleModuleAssignment:
                    gApp.engine.badgeOfAssignment = 0;
                    break;
                case kKuleModuleChating:
                    gApp.engine.badgeOfChating = 0;
                    break;
                case kKuleModuleAssess:
                    gApp.engine.badgeOfAssess = 0;
                    break;
                case kKuleModuleCCTV: {
                    if (self.videoMember.account.length > 0
                        && self.videoMember.password.length > 0) {
                    }
                    else if (self.defaultVideoMember.account.length > 0
                             && self.defaultVideoMember.password.length > 0) {
                    }
                    else {
                        _actionToCCTV = YES;
                        [self performSelector:@selector(reloadVideoMember) withObject:nil afterDelay:0];
                        return;
                    }
                    break;
                }
                default:
                    break;
            }
            
#if COCOBABYS_USE_IM
            if (moduleType == kKuleModuleChating) {
                [self openRCIM];
            }
            else {
                [self performSegueWithIdentifier:segueNames[moduleType] sender:nil];
            }
#else
            [self performSegueWithIdentifier:segueNames[moduleType] sender:nil];
#endif
        }
        else {
            //            [gApp alert:@"权限不足，请联系幼儿园开通权限，谢谢。"];
        }
    }
    else {
        CSLog(@"未响应的模块%@", @(moduleType));
    }
}

- (IBAction)onBtnSettingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.settings3" sender:nil];
}

- (IBAction)onBtnSchoolInfoClicked:(id)sender {
    if (_schoolInfo) {
        [self performSegueWithIdentifier:@"segue.aboutschool" sender:nil];
    }
    else {
        [self doGetSchoolInfo:^{
            [self performSegueWithIdentifier:@"segue.aboutschool" sender:nil];
        }];
    }
}

- (void)openRCIM {
    NSArray* arr1 = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_GROUP),@(ConversationType_SYSTEM)];
    NSArray* arr2 = nil;
    CBIMChatListViewController* ctrl = [[CBIMChatListViewController alloc] initWithDisplayConversationTypes:arr1
                                                                                 collectionConversationType:arr2];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)onBtnClassInfoClicked:(id)sender {
#if COCOBABYS_FEATURE_COMMERCIAL
    BOOL enabledCommercial = gApp.engine.preferences.enabledCommercial;
    if (enabledCommercial) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Commercial" bundle:nil];
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
        self.badgeCommercial.badgeText = nil;
    }
#endif
}

- (void)checkCCTVShown {
    if (_schoolInfo) {
        [self doCheckCCTVShown];
    }
    else {
        [self doGetSchoolInfo:^{
            [self doCheckCCTVShown];
        }];
    }
}

- (void)doCheckCCTVShown {
    if (_schoolInfo) {
        
    }
}


#pragma mark - Private
- (void)getRelationshipInfos {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* relationships = [NSMutableArray array];
        
        for (id relationshipJson in dataJson) {
            CSKuleRelationshipInfo* relationshipInfo = [CSKuleInterpreter decodeRelationshipInfo:relationshipJson];
            if (relationshipInfo.parent && relationshipInfo.child) {
                [relationships addObject:relationshipInfo];
            }
        }
        
        gApp.engine.relationships = [NSArray arrayWithArray:relationships];
        
        CSKuleRelationshipInfo* relationshipInfo = [gApp.engine.relationships firstObject];
        
        if (gApp.engine.preferences.currentRelationshipUid > 0) {
            for (CSKuleRelationshipInfo* r in gApp.engine.relationships) {
                if (r.uid == gApp.engine.preferences.currentRelationshipUid) {
                    relationshipInfo = r;
                    break;
                }
            }
        }
        
        if(relationshipInfo) {
            gApp.engine.currentRelationship = relationshipInfo;
            [gApp hideAlert];
            
            [self handlePendingNotification];
            
            //
            
            [[CBIMDataSource sharedInstance] reloadRelationships];
            [[CBIMDataSource sharedInstance] reloadTeachers];
        }
        else {
            [gApp alert:@"没有关联宝宝信息"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"获取宝宝信息"];
    [gApp.engine.httpClient reqGetFamilyRelationship:gApp.engine.loginInfo.accountName
                           inKindergarten:gApp.engine.loginInfo.schoolId
                                  success:sucessHandler
                                  failure:failureHandler];
}

- (void)reloadVideoMember {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        self.videoMember = [CSKuleInterpreter decodeVideoMember:dataJson];
        [gApp hideAlert];
        if(_actionToCCTV) {
            [self performSegueWithIdentifier:@"segue.cctv" sender:nil];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp hideAlert];
        [self performSelector:@selector(reloadDefaultVideoMember) withObject:nil afterDelay:0];
    };
    
    if(_actionToCCTV) {
        [gApp waitingAlert:@"请求数据中"];
    }
    [gApp.engine.httpClient reqGetVideoMemberOfKindergarten:gApp.engine.loginInfo.schoolId
                                    withParentId:gApp.engine.currentRelationship.parent.parentId
                                         success:sucessHandler
                                         failure:failureHandler];
}

- (void)reloadDefaultVideoMember {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        self.defaultVideoMember = [CSKuleInterpreter decodeVideoMember:dataJson];
        [gApp hideAlert];
        if(_actionToCCTV) {
            [self performSegueWithIdentifier:@"segue.cctv" sender:nil];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:@"还未开通看宝宝功能，该功能可以让家长通过视频，实时查看孩子在幼儿园的动态,如有需要请联系幼儿园开通。"];
    };
    
    if(_actionToCCTV) {
        [gApp waitingAlert:@"请求数据中"];
    }
    [gApp.engine.httpClient reqGetDefaultVideoMemberOfKindergarten:gApp.engine.loginInfo.schoolId
                                                success:sucessHandler
                                                failure:failureHandler];
}

//- (void)getEmployeeInfos {
//    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
//        NSMutableArray* employeeInfos = [NSMutableArray array];
//
//        for (id employeeInfoJson in dataJson) {
//            CSKuleEmployeeInfo* employeeInfo = [CSKuleInterpreter decodeEmployeeInfo:employeeInfoJson];
//            [employeeInfos addObject:employeeInfo];
//        }
//
//        gApp.engine.employees = [NSArray arrayWithArray:employeeInfos];
//        [gApp hideAlert];
//    };
//
//    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
//        CSLog(@"failure:%@", error);
//        [gApp alert:[error localizedDescription]];
//    };
//
//    [gApp waitingAlert:@"获取信息..."];
//    [gApp.engine.httpClient reqGetEmployeeListOfKindergarten:gApp.engine.loginInfo.schoolId
//                                          success:sucessHandler
//                                          failure:failureHandler];
//}

- (void)showBanner:(NSString*)msg {
    CSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    ALAlertBannerStyle randomStyle = ALAlertBannerStyleNotify;
    ALAlertBannerPosition position = ALAlertBannerPositionUnderNavBar;
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:appDelegate.window
                                                        style:randomStyle
                                                     position:position
                                                        title:@"您有新的通知"
                                                     subtitle:msg
                                                  tappedBlock:^(ALAlertBanner *alertBanner) {
                                                      [alertBanner hide];
                                                  }];
    banner.secondsToShow = 2;
    banner.showAnimationDuration = 0.3;
    banner.hideAnimationDuration = 0.3;
    [banner show];
    
#if TARGET_OS_IPHONE
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
    
    AudioServicesPlaySystemSound(1007);
}

- (void)handlePendingNotification {
    NSDictionary* notiInfo = gApp.engine.pendingNotificationInfo;
    if (gApp.engine.pendingNotificationInfo
        && gApp.engine.currentRelationship
        && notiInfo) {
        gApp.engine.pendingNotificationInfo = nil;
        
        NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:notiInfo];
        if (pushServiceData) {
            CSLog(@"该远程推送包含来自融云的推送服务");
            for (id key in [pushServiceData allKeys]) {
                CSLog(@"key = %@, value = %@", key, pushServiceData[key]);
            }
            
            [self openRCIM];
        } else {
            CSLog(@"该远程推送不包含来自融云的推送服务");
            
            CSKuleCheckInOutLogInfo* info = [CSKuleInterpreter decodeCheckInOutLogInfo:notiInfo];
            if (info) {
                CSKuleNewsDetailsViewController* ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CSKuleNewsDetailsViewController"];
                ctrl.navigationItem.title = @"刷卡信息";
                ctrl.checkInOutLogInfo = info;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
        }
    }
}


#pragma mark - Commercial
- (void)reloadContractorItemDataList {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        if ([dataJson count] >= 5) {
            [self performSelectorInBackground:@selector(reloadActivityItemDataList)
                                   withObject:nil];
        }
        else {
            CSLog(@"ContractorItemDataList count=%ld", [dataJson count]);
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        [gApp.engine.httpClient reqGetContractorListOfKindergarten:gApp.engine.loginInfo.schoolId
                                           withCategory:-1
                                                   from:-1
                                                     to:-1
                                                   most:-1
                                                success:sucessHandler
                                                failure:failureHandler];
    }
}

- (void)reloadActivityItemDataList {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        if ([dataJson count] >= 5) {
            gApp.engine.preferences.enabledCommercial = YES;
            [self performSelectorOnMainThread:@selector(updateCommercialStatus) withObject:nil waitUntilDone:YES];
        }
        else {
            CSLog(@"ActivityItemDataList count=%ld", [dataJson count]);
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        [gApp.engine.httpClient reqGetActivityListOfKindergarten:gApp.engine.loginInfo.schoolId
                                                 from:-1
                                                   to:-1
                                                 most:-1
                                              success:sucessHandler
                                              failure:failureHandler];
    }
}

#pragma mark - Private
- (void)showIntroViewsIfNeeded {
    if (!gApp.engine.preferences.guideHomeShown) {
        [self showIntroViews];
    }
    else {
    }
}

-(void)showIntroViews {
    //float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    /*
     NSArray* introImageNames = @[@"guide-1.png", @"guide-2.png", @"guide-3.png", @"guide-4.png"];
     if (!IS_IPHONE4) {
     introImageNames = @[@"guide-1-568h.png", @"guide-2-568h.png", @"guide-3-568h.png", @"guide-4-568h.png"];
     }
     */
    NSArray* introImageNames = @[@"v2_8-guide-home"];
    
    NSMutableArray* introPages = [NSMutableArray array];
    for (NSString* imageName in introImageNames) {
        EAIntroPage* page = [EAIntroPage page];
        UIImageView* imageV = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
        imageV.image = [UIImage imageNamed:imageName];
        page.customView = imageV;
        [introPages addObject:page];
    }
    
    UIButton* skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize viewSize = self.navigationController.view.bounds.size;
    skipButton.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.navigationController.view.bounds
                                                   andPages:introPages];
    intro.skipButton = skipButton;
    intro.backgroundColor = [UIColor clearColor];
    intro.scrollView.bounces = NO;
    intro.swipeToExit = NO;
    intro.easeOutCrossDisolves = NO;
    intro.showSkipButtonOnlyOnLastPage = YES;
    intro.pageControl.hidden = YES;
    [intro setDelegate:self];
    [intro showInView:self.navigationController.view animateDuration:0];
}

#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
    gApp.engine.preferences.guideHomeShown = YES;
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex {
    
}

@end
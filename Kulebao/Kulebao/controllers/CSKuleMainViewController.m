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

@interface CSKuleMainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImagePickerController* _imgPicker;
    CSTextFieldDelegate* _nickFieldDelegate;
    NSMutableArray* _badges;
    NSArray* _moduleInfos;
}

@property (weak, nonatomic) IBOutlet UILabel *labSchoolName;
@property (weak, nonatomic) IBOutlet UILabel *labClassName;
@property (weak, nonatomic) IBOutlet UILabel *labChildNick;
@property (weak, nonatomic) IBOutlet UIImageView *imgChildPortrait;
@property (weak, nonatomic) IBOutlet UIView *viewChildContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContent;

@property (weak, nonatomic) IBOutlet UIButton *btnClassInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnSchoolInfo;

@property (nonatomic, strong) CSKuleSchoolInfo* schoolInfo;
@property (nonatomic, strong) CSKuleVideoMember* videoMember;

- (IBAction)onBtnShowChildMenuListClicked:(id)sender;
- (IBAction)onBtnSettingsClicked:(id)sender;
- (IBAction)onBtnSchoolInfoClicked:(id)sender;
- (IBAction)onBtnClassInfoClicked:(id)sender;

@end

@implementation CSKuleMainViewController
@synthesize schoolInfo = _schoolInfo;
@synthesize videoMember = _videoMember;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"titlebar-1-bg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont: [UIFont systemFontOfSize:20], UITextAttributeTextColor:[UIColor whiteColor]}];
    
    self.labClassName.text = nil;
    self.labSchoolName.text = gApp.engine.loginInfo.schoolName;
    self.labChildNick.text = nil;
    self.imgChildPortrait.layer.cornerRadius = 6.0;
    self.imgChildPortrait.clipsToBounds = YES;
    self.btnClassInfo.userInteractionEnabled = NO;
    
    _nickFieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    _nickFieldDelegate.maxLength = kKuleNickMaxLength;
    
    [self setupModules];
    
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
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfAssignment"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfChating"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfAssess"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [self performSelector:@selector(getRelationshipInfos) withObject:nil afterDelay:0];
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
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfAssignment"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfChating"];
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfAssess"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CSLog(@"%@ changed.", keyPath);
    if ((object == gApp.engine) && [keyPath isEqualToString:@"currentRelationship"]) {
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
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleNews];
        if (gApp.engine.badgeOfNews > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的园内公告"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfRecipe"]) {
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleRecipe];
        if (gApp.engine.badgeOfRecipe > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的每周食谱"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfCheckin"]) {
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleCheckin];
        if (gApp.engine.badgeOfCheckin > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的接送消息"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfSchedule"]) {
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleSchedule];
        if (gApp.engine.badgeOfSchedule > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的课程表"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfAssignment"]) {
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleAssignment];
        if (gApp.engine.badgeOfAssignment > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的亲子作业"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfChating"]) {
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleChating];
        if (gApp.engine.badgeOfChating > 0) {
            badgeView.badgeText = @"新";
            [self showBanner:@"您收到新的家园互动"];
        }
        else {
            badgeView.badgeText = nil;
        }
    }
    else if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfAssess"]) {
        JSBadgeView* badgeView = [_badges objectAtIndex:kKuleModuleAssess];
        if (gApp.engine.badgeOfAssess > 0) {
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

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    [_scrollContent flashScrollIndicators];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.aboutschool"]) {
        CSKuleAboutSchoolViewController* destCtrl = segue.destinationViewController;
        destCtrl.schoolInfo = _schoolInfo;
    }
    else if ([segue.identifier isEqualToString:@"segue.cctv"]) {
        CSKuleCCTVMainTableViewController* destCtrl = segue.destinationViewController;
        destCtrl.videoMember = self.videoMember;
    }
}

#pragma mark - UI
- (void)setupModules {
    _moduleInfos =
    @[
      @[@"园内公告", @"btn-func-6.png", @(kKuleModuleNews)],
      @[@"每周食谱", @"btn-func-2.png", @(kKuleModuleRecipe)],
      @[@"接送信息", @"btn-func-3.png", @(kKuleModuleCheckin)],
      @[@"课程表",  @"btn-func-5.png", @(kKuleModuleSchedule)],
      @[@"亲子作业", @"btn-func-8.png", @(kKuleModuleAssignment)],
      @[@"家园互动", @"btn-func-7.png", @(kKuleModuleChating)],
      @[@"在园表现", @"btn-func-4.png", @(kKuleModuleAssess)],
      @[@"成长经历", @"exp.png", @(kKuleModuleHistory)],
      @[@"看宝贝", @"watch.png", @(kKuleModuleCCTV)],
      ];
    
    _badges = [NSMutableArray arrayWithCapacity:kKuleModuleSize];
    
    const CGSize kModuleIconSize = CGSizeMake(71, 71);
    const CGSize kModuleTitleSize = CGSizeMake(71, 21);
    const NSInteger kModuleColumns = 3;
    //const NSInteger kModuleRows = (kKuleModuleSize + MAX((kKuleModuleSize -1), 0)) / kModuleColumns;
    const CGFloat kModuleTopMagin = 5;
    const CGFloat kModuleRowSpace = 5;
    const CGFloat kModuleColumnSpace = (_scrollContent.bounds.size.width - kModuleIconSize.width*kModuleColumns)/(kModuleColumns*2.0);
    
    CGFloat xx = 0.0;
    CGFloat yy = 0.0;
    NSInteger row = 0;
    NSInteger col = 0;
    
    for (UIView* v in _scrollContent.subviews) {
        [v removeFromSuperview];
    }
    
    for (NSInteger i=0; i<kKuleModuleSize; i++) {
        row = i / kModuleColumns;
        col = i % kModuleColumns;
        xx = kModuleColumnSpace + col * (kModuleIconSize.width+2*kModuleColumnSpace);
        yy = kModuleTopMagin + row*(kModuleIconSize.height+kModuleTitleSize.height+kModuleRowSpace);
        
        UIButton* btnIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* moduleName = _moduleInfos[i][0];
        NSString* moduleIconName = _moduleInfos[i][1];
        NSInteger moduleType = [_moduleInfos[i][2] integerValue];
        [btnIcon setBackgroundImage:[UIImage imageNamed:moduleIconName] forState:UIControlStateNormal];
        btnIcon.tag = moduleType;
        btnIcon.frame = CGRectMake(xx, yy, kModuleIconSize.width, kModuleIconSize.height);
        [_scrollContent addSubview:btnIcon];
        [btnIcon addTarget:self action:@selector(onBtnModulesClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        yy += kModuleIconSize.height;
        UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(xx, yy, kModuleTitleSize.width, kModuleTitleSize.height)];
        labTitle.textColor = UIColorRGB(0xCC, 0x66, 0x33);
        labTitle.font = [UIFont boldSystemFontOfSize:14];
        labTitle.text = moduleName;
        labTitle.textAlignment = NSTextAlignmentCenter;
        labTitle.backgroundColor = [UIColor clearColor];
        [_scrollContent addSubview:labTitle];
        
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:btnIcon
                                                               alignment:JSBadgeViewAlignmentTopRight];
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
    if (childInfo) {
        CSLog(@"childInfo:%@", childInfo);
        self.labClassName.text = childInfo.className;
        self.labSchoolName.text = gApp.engine.loginInfo.schoolName;
        self.labChildNick.text = childInfo.displayNick;
        
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:childInfo.portrait];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/256/h/256"];
        
        SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority |SDWebImageAllowInvalidSSLCertificates;
        
        if (reloadPortrait) {
            options = options | SDWebImageRefreshCached;
        }
        
        UIImage* placeholderImage = [UIImage imageNamed:@"default_child_head_icon.png"];
        if (self.imgChildPortrait.image) {
            placeholderImage = self.imgChildPortrait.image;
        }
        [self.imgChildPortrait  sd_setImageWithURL:qiniuImgUrl
                                  placeholderImage:placeholderImage
                                           options:options];
        
    }
    else {
        [gApp alert:@"没有宝宝信息。"];
    }
}

- (void)doChangeChildNick {
    NSString *title = @"设置宝宝昵称";
	NSString *message = @"";
	
	AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    alert.alertViewStyle = AHAlertViewStylePlainTextInput;
    
    UITextField* field = [alert textFieldAtIndex:0];
    field.placeholder = @"请输入宝宝的昵称";
    field.text = gApp.engine.currentRelationship.child.nick;
    field.keyboardAppearance = UIKeyboardAppearanceDefault;
    field.background = [[UIImage imageNamed:@"input-bg-0.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 10)];
    field.borderStyle = UITextBorderStyleBezel;
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
            [gApp.engine reqUpdateChildInfo:cp
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
            [gApp.engine reqUpdateChildInfo:cp
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
            [gApp.engine reqUpdateChildInfo:cp
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

- (void)doGetSchoolInfo {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        id schoolInfoJson = [dataJson valueForKeyNotNull:@"school_info"];
        
        CSKuleSchoolInfo* schoolInfo = nil;
        if (schoolInfoJson) {
            schoolInfo = [CSKuleInterpreter decodeSchoolInfo:schoolInfoJson];
        }
        
        if(schoolInfo) {
            _schoolInfo = schoolInfo;
            [self performSegueWithIdentifier:@"segue.aboutschool" sender:nil];
            [gApp hideAlert];
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
    [gApp.engine reqGetSchoolInfoOfKindergarten:gApp.engine.loginInfo.schoolId
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
    [gApp.engine reqUploadToQiniu:imgData
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
    
    KxMenuItem* item3 = [KxMenuItem menuItem:@"从相机拍摄头像"
                                       image:nil
                                      target:self
                                      action:@selector(doChangePortraitFromCamera)];
    
    KxMenuItem* item4 = [KxMenuItem menuItem:@"从相册选择头像"
                                       image:nil
                                      target:self
                                      action:@selector(doChangePortraitFromPhoto)];
    
    [KxMenu setTintColor:UIColorRGB(0xCC, 0x66, 0x33)];
    [KxMenu showMenuInView:self.view
                  fromRect:self.viewChildContainer.frame
                 menuItems:@[item1, item2, item3, item4]];
}

#pragma mark - UI Actions
- (BOOL)checkModuleTypeForMemberStatus:(NSInteger)moduleType {
    BOOL ok = NO;
    if ([gApp.engine.loginInfo.memberStatus isEqualToString:@"free"]) {
        switch (moduleType) {
            case kKuleModuleNews:
            case kKuleModuleCheckin:
                ok = YES;
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
    };
    
    if (moduleType < kKuleModuleSize && moduleType < sizeof(segueNames)) {
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
                    else {
                        [self performSelector:@selector(reloadVideoMember) withObject:nil afterDelay:0];
                        return;
                    }
                    break;
                }
                default:
                    break;
            }
            
            [self performSegueWithIdentifier:segueNames[moduleType] sender:nil];
        }
        else {
            [gApp alert:@"权限不足，请联系幼儿园开通权限，谢谢。"];
        }
    }
}

- (IBAction)onBtnSettingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.settings" sender:nil];
}

- (IBAction)onBtnSchoolInfoClicked:(id)sender {
    if (_schoolInfo) {
        [self performSegueWithIdentifier:@"segue.aboutschool" sender:nil];
    }
    else {
        [self doGetSchoolInfo];
    }
}

- (IBAction)onBtnClassInfoClicked:(id)sender {
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
        if(relationshipInfo) {
            gApp.engine.currentRelationship = relationshipInfo;
            [gApp hideAlert];
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
    [gApp.engine reqGetFamilyRelationship:gApp.engine.loginInfo.accountName
                           inKindergarten:gApp.engine.loginInfo.schoolId
                                  success:sucessHandler
                                  failure:failureHandler];
}

- (void)reloadVideoMember {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        self.videoMember = [CSKuleInterpreter decodeVideoMember:dataJson];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp.engine reqGetVideoMemberOfKindergarten:gApp.engine.loginInfo.schoolId
                                    withParentId:gApp.engine.currentRelationship.parent.parentId
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
//    [gApp.engine reqGetEmployeeListOfKindergarten:gApp.engine.loginInfo.schoolId
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

@end

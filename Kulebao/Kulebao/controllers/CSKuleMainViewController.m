//
//  CSKuleMainViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleMainViewController.h"
#import "CSAppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "KxMenu.h"
#import "AHAlertView.h"

@interface CSKuleMainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImagePickerController* _imgPicker;
}
@property (weak, nonatomic) IBOutlet UILabel *labSchoolName;
@property (weak, nonatomic) IBOutlet UILabel *labClassName;
@property (weak, nonatomic) IBOutlet UILabel *labChildNick;
@property (weak, nonatomic) IBOutlet UIImageView *imgChildPortrait;
@property (weak, nonatomic) IBOutlet UIView *viewChildContainer;

- (IBAction)onBtnShowChildMenuListClicked:(id)sender;

- (IBAction)onBtnSettingsClicked:(id)sender;
- (IBAction)onBtnNewsListClicked:(id)sender;
- (IBAction)onBtnRecipeClicked:(id)sender;
- (IBAction)onBtnCheckinInfoClicked:(id)sender;
- (IBAction)onBtnScheduleInfoClicked:(id)sender;
- (IBAction)onBtnHomeworkClicked:(id)sender;
- (IBAction)onBtnChatingClicked:(id)sender;

@end

@implementation CSKuleMainViewController

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
    
    [gApp.engine addObserver:self
                  forKeyPath:@"currentRelationship"
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == gApp.engine) && [keyPath isEqualToString:@"currentRelationship"]) {
        CSLog(@"currentRelationship changed.");
        [self updateUI];
    }
}

#pragma mark - UI
- (void)updateUI {
    CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
    if (childInfo) {
        self.labClassName.text = childInfo.className;
        self.labSchoolName.text = gApp.engine.loginInfo.schoolName;
        self.labChildNick.text = childInfo.nick;
        self.imgChildPortrait.image = nil;
        [self.imgChildPortrait setImageWithURL:[gApp.engine urlFromPath:childInfo.portrait]];
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

    [alert setCancelButtonTitle:@"取消" block:^{

	}];
    
	[alert addButtonWithTitle:@"确定" block:^{
        [self doUpdateChildNick:field.text];
	}];
    
    [alert show];
}

- (void)doUpdateChildNick:(NSString*)nick {
    if (nick.length > 0) {
        CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
        CSKuleChildInfo* cp = [childInfo copy];
        cp.nick = nick;
        
        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            CSLog(@"success.");
            [gApp alert:@"修改成功"];
            
            CSKuleChildInfo* cc = [CSKuleInterpreter decodeChildInfo:dataJson];
            childInfo.nick = cc.nick;
            
            [self updateUI];
        };
        
        FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
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
        [gApp alert:@"昵称不能为空"];
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                               }];
    
    if (picker == _imgPicker) {
        _imgPicker = nil;
    }
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
                                      target:nil
                                      action:nil];
    
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

- (IBAction)onBtnSettingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.settings" sender:nil];
}

- (IBAction)onBtnNewsListClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.newslist" sender:nil];
}

- (IBAction)onBtnRecipeClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.recipe" sender:nil];
}

- (IBAction)onBtnCheckinInfoClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.checkin" sender:nil];
}

- (IBAction)onBtnScheduleInfoClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.schedule" sender:nil];
}

- (IBAction)onBtnHomeworkClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.homework" sender:nil];
}

- (IBAction)onBtnChatingClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.chating" sender:nil];
}

#pragma mark - Private
- (void)getRelationshipInfos {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSMutableArray* relationships = [NSMutableArray array];
        
        for (id relationshipJson in dataJson) {
            CSKuleRelationshipInfo* relationshipInfo = [CSKuleInterpreter decodeRelationshipInfo:relationshipJson];
            [relationships addObject:relationshipInfo];
        }
        
        gApp.engine.relationships = [NSArray arrayWithArray:relationships];
        
        CSKuleRelationshipInfo* relationshipInfo = [gApp.engine.relationships firstObject];
        gApp.engine.currentRelationship = relationshipInfo;
        
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
    };
    
    [gApp waitingAlert:@"获取宝宝信息"];
    [gApp.engine reqGetFamilyRelationship:gApp.engine.loginInfo.accountName
                           inKindergarten:gApp.engine.loginInfo.schoolId
                                  success:sucessHandler
                                  failure:failureHandler];
}

@end

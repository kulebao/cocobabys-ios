//
//  CSKuleSettings2ViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/26/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSKuleSettings2ViewController.h"
#import "AHAlertView.h"
#import "CSAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "KxMenu.h"
#import "UIImage+CSExtends.h"
#import "UIActionSheet+BlocksKit.h"

@interface CSKuleSettings2ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImagePickerController* _imgPicker;
    CSTextFieldDelegate* _nickFieldDelegate;
    CSTextFieldDelegate* _relationshipFieldDelegate;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDev;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UIView *viewPortrait;
- (IBAction)onBtnPortraitClicked:(id)sender;

@end

@implementation CSKuleSettings2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self customizeBackBarItem];
    self.imgPortrait.layer.cornerRadius = self.imgPortrait.bounds.size.width/2.0;
    self.imgPortrait.clipsToBounds = YES;
    self.imgPortrait.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imgPortrait.layer.borderWidth = 2;
    
    _nickFieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    _nickFieldDelegate.maxLength = kKuleParentNameMaxLength;
    
    _relationshipFieldDelegate = [[CSTextFieldDelegate alloc] initWithType:kCSTextFieldDelegateNormal];
    _relationshipFieldDelegate.maxLength = kKuleRelationshipMaxLength;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    // 设置行间距
    NSString* text = [NSString stringWithFormat:@"%@ %@\n%@",
                      SAFE_STRING(gApp.engine.currentRelationship.relationship),
                      SAFE_STRING(gApp.engine.currentRelationship.parent.name),
                      SAFE_STRING(gApp.engine.currentRelationship.parent.phone)];
    NSMutableParagraphStyle* ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 8;
    NSMutableAttributedString* atrText = [[NSMutableAttributedString alloc] initWithString:text];
    [atrText addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, text.length)];
    self.labName.attributedText = atrText;
    
    NSURL* qiniuImgUrl = [gApp.engine urlFromPath:gApp.engine.currentRelationship.parent.portrait];
    qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/256/h/256"];
    
    [self.imgPortrait sd_setImageWithURL:qiniuImgUrl
                        placeholderImage:[UIImage imageNamed:@"chat_head_icon.gif"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    if (COCOBABYS_DEV_MODEL) {
        numberOfSections = 3;
    }
    return numberOfSections;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0,0,360,20)];
    v.backgroundColor = [UIColor whiteColor];
    return v;
}

#if 0
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section==1 && row==4) {
        // Exit
        [self onLogoutClicked];
    }
    else if (section==2 && row==0) {
        // DEV
    }
}

- (void)onLogoutClicked {
    NSString *title = @"提示";
    NSString *message = @"确定要退出登录？退出后无法接收任何消息！";
    
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:@"取消" block:^{
    }];
    
    [alert addButtonWithTitle:@"确定" block:^{
        [self performSelector:@selector(doLogout) withObject:nil];
    }];
    
    [alert show];
}

#pragma mark - Private
- (void)doLogout {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        if (bindInfo.errorCode == 0) {
            [gApp hideAlert];
        }
        else {
            CSLog(@"[4]doReceiveBindInfo error_code=%ld", bindInfo.errorCode);
            [gApp alert:@"解除绑定失败。"];
        }
        
        [gApp logout];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
        [gApp logout];
    };
    
    [gApp waitingAlert:@"注销登录..."];
    [gApp.engine.httpClient reqUnbindWithSuccess:sucessHandler failure:failureHandler];
}

- (IBAction)onBtnPortraitClicked:(id)sender {
//    KxMenuItem* item1 = [KxMenuItem menuItem:@"从相机拍摄头像"
//                                       image:nil
//                                      target:self
//                                      action:@selector(doChangePortraitFromCamera)];
//    
//    KxMenuItem* item2 = [KxMenuItem menuItem:@"从相册选择头像"
//                                       image:nil
//                                      target:self
//                                      action:@selector(doChangePortraitFromPhoto)];
    
    KxMenuItem* item1 = [KxMenuItem menuItem:@"设置家长姓名"
                                       image:nil
                                      target:self
                                      action:@selector(doChangeName)];
    
    KxMenuItem* item2 = [KxMenuItem menuItem:@"设置亲属关系"
                                       image:nil
                                      target:self
                                      action:@selector(doChangeRelationship)];
    
    KxMenuItem* item3 = [KxMenuItem menuItem:@"设置家长头像"
                                       image:nil
                                      target:self
                                      action:@selector(doChangePortrait)];
    
    [KxMenu setTintColor:[UIColor colorWithRed:0.129f green:0.565f blue:0.839f alpha:1.0f]];
    [KxMenu showMenuInView:self.view
                  fromRect:self.viewPortrait.frame
                 menuItems:@[item1, item2, item3]];
}

- (void)doUpdateParentPortrait:(NSString*)portrait withImage:(UIImage*)img {
    if (portrait.length > 0) {
        CSKuleParentInfo* parentInfo = gApp.engine.currentRelationship.parent;
        if (parentInfo) {
            CSKuleParentInfo* cp = [parentInfo copy];
            cp.portrait = portrait;
            
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                CSLog(@"success.");
                [gApp alert:@"更新成功"];
                
                CSKuleParentInfo* cc = [CSKuleInterpreter decodeParentInfo:dataJson];
                for (CSKuleRelationshipInfo* relationship in gApp.engine.relationships) {
                    if ([relationship.parent.parentId isEqualToString:cc.parentId]) {
                        relationship.parent.portrait = cc.portrait;
                    }
                }
                
                self.imgPortrait.image = img;
                [self reloadData];
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp alert:[error localizedDescription]];
            };
            
            [gApp waitingAlert:@"更新家长头像中"];
            [gApp.engine.httpClient reqUpdateParentInfo:cp
                              inKindergarten:gApp.engine.loginInfo.schoolId
                                     success:sucessHandler
                                     failure:failureHandler];
            
        }
        else {
            [gApp alert:@"没有家长信息"];
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


- (void)doChangeName {
    NSString *title = @"设置家长姓名";
    NSString *message = [NSString stringWithFormat:@"您最多可以输入%d个字", kKuleParentNameMaxLength];
    
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    alert.alertViewStyle = AHAlertViewStylePlainTextInput;
    alert.messageTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    
    UITextField* field = [alert textFieldAtIndex:0];
    field.placeholder = @"请输入家长姓名";
    field.text = gApp.engine.currentRelationship.parent.name;
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
//        [self doUpdateChildNick:field.text];
    }];
    
    [alert show];
}

- (void)doChangeRelationship {
    NSString *title = @"设置亲属关系";
    NSString *message = [NSString stringWithFormat:@"您最多可以输入%d个字", kKuleRelationshipMaxLength];
    
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    alert.alertViewStyle = AHAlertViewStylePlainTextInput;
    alert.messageTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    
    UITextField* field = [alert textFieldAtIndex:0];
    field.placeholder = @"请输入亲属关系";
    field.text = gApp.engine.currentRelationship.relationship;
    field.keyboardAppearance = UIKeyboardAppearanceDefault;
    //field.background = [[UIImage imageNamed:@"input-bg-0.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 50, 10, 10)];
    //field.borderStyle = UITextBorderStyleBezel;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.backgroundColor = [UIColor clearColor];
    field.font = [UIFont systemFontOfSize:14];
    field.delegate = _relationshipFieldDelegate;
    
    [alert setCancelButtonTitle:@"取消" block:^{
        
    }];
    
    [alert addButtonWithTitle:@"确定" block:^{
        //        [self doUpdateChildNick:field.text];
    }];
    
    [alert show];
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
    UIImage* img = info[UIImagePickerControllerEditedImage];
    NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
    
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSString* imgFileName = [NSString stringWithFormat:@"parent_photo/%@/%@/%@_%@.jpg",
                             @(gApp.engine.loginInfo.schoolId),
                             gApp.engine.currentRelationship.parent.parentId,
                             gApp.engine.currentRelationship.parent.parentId,
                             @(timestamp)];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* name = [dataJson valueForKeyNotNull:@"name"];
        NSString* portrait = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, name];
        //self.imgChildPortrait.image = img;
        UIImage* cropImg = [img imageByScalingAndCroppingForSize:CGSizeMake(256, 256)];
        [self doUpdateParentPortrait:portrait withImage:cropImg];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传家长头像中"];
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

@end

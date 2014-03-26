//
//  CSKuleChatingViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingViewController.h"
#import "CSKuleNoticeCell.h"
#import "PullTableView.h"
#import "CSAppDelegate.h"
#import "CSKuleChatingEditorViewController.h"

@interface CSKuleChatingViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CSKuleChatingEditorViewControllerDelegate> {
    UIImagePickerController* _imgPicker;
    NSMutableArray* _chatingMsgList;
}

@property (weak, nonatomic) IBOutlet PullTableView *tableview;
- (IBAction)onBtnEditorClicked:(id)sender;
- (IBAction)onBtnCameraClicked:(id)sender;
- (IBAction)onBtnPhotosClicked:(id)sender;

@end

@implementation CSKuleChatingViewController
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
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.pullDelegate = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    _chatingMsgList = [NSMutableArray array];
    [self doReloadChatingMsgsFrom:-1 to:-1 most:-1];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatingMsgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleNoticeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNoticeCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleNoticeCell" owner:nil options:nil];
        cell = [nibs firstObject];
    }
    
    CSKuleChatMsg* msg = [_chatingMsgList objectAtIndex:indexPath.row];
    cell.labDate.text = [[NSDate dateWithTimeIntervalSince1970:msg.timestamp] isoDateTimeString];
    cell.labTitle.text = msg.sender;
    cell.labContent.text = msg.content;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleChatMsg* msg = [_chatingMsgList objectAtIndex:indexPath.row];
    CGFloat height = 0.0;
    if (msg.image.length > 0) {
        height = 80;
    }
    else {
        CGSize sz = [self textSize:msg.content];
        height = sz.height + 20;
    }
    
    return 110.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [self performSelector:@selector(refreshTable)
               withObject:nil
               afterDelay:3.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    [self performSelector:@selector(loadMoreDataToTable)
               withObject:nil
               afterDelay:3.0f];
}

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.tableview.pullLastRefreshDate = [NSDate date];
    self.tableview.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    self.tableview.pullTableIsLoadingMore = NO;
}


#pragma mark - UI Actions
- (IBAction)onBtnEditorClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.chatingEditor" sender:nil];
}

- (IBAction)onBtnCameraClicked:(id)sender {
#if TARGET_IPHONE_SIMULATOR
#else
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imgPicker.allowsEditing = NO;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
#endif
}

- (IBAction)onBtnPhotosClicked:(id)sender {
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imgPicker.allowsEditing = NO;
    _imgPicker.delegate = self;
    [self presentViewController:_imgPicker animated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* img = info[UIImagePickerControllerOriginalImage];
    NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
    /*
     家园互动时，发布的图片
     chat_icon/93740362/13408654680/1394455093918.jpg
     93740362  学校id
     13408654680 家长手机号
     1394455093918  发布时间搓，1970年至今的毫秒数
     */
    NSString* imgFileName = [NSString stringWithFormat:@"chat_icon/%@/%@/%@.jpg",
                             @(gApp.engine.loginInfo.schoolId),
                             gApp.engine.loginInfo.accountName,
                             @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
    
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSString* imgUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, imgFileName];
        [self doSendPicture:imgUrl];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传图片中"];
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

#pragma mark - Private
- (void)doSendPicture:(NSString*)imgUrl {
    [self doSendMsg:nil withImage:imgUrl];
}

- (void)doSendText:(NSString*)msgBody {
    [self doSendMsg:msgBody withImage:nil];
}

- (void)doSendMsg:(NSString*)msgBody withImage:(NSString*)imgUrl {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSMutableArray* chatMsgs = [NSMutableArray array];
        
        if ([dataJson isKindOfClass:[NSArray class]]) {
            for (id chatMsgJson in dataJson) {
                CSKuleChatMsg* chatMsg = [CSKuleInterpreter decodeChatMsg:chatMsgJson];
                [chatMsgs addObject:chatMsg];
            }
        }
        else if ([dataJson isKindOfClass:[NSDictionary class]]) {
            CSKuleChatMsg* chatMsg = [CSKuleInterpreter decodeChatMsg:dataJson];
            [chatMsgs addObject:chatMsg];
        }
        
        [gApp alert:@"发送成功 ^_^"];
        [self.navigationController popToViewController:self animated:YES];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"发送中..."];
    [gApp.engine reqSendChatingMsgs:msgBody
                          withImage:imgUrl
                     toKindergarten:gApp.engine.loginInfo.schoolId
                       retrieveFrom:-1
                            success:sucessHandler
                            failure:failureHandler];
}

- (void)doReloadChatingMsgsFrom:(NSInteger)fromId to:(NSInteger)toId most:(NSInteger)most {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSMutableArray* chatMsgs = [NSMutableArray array];
        
        if ([dataJson isKindOfClass:[NSArray class]]) {
            for (id chatMsgJson in dataJson) {
                CSKuleChatMsg* chatMsg = [CSKuleInterpreter decodeChatMsg:chatMsgJson];
                [chatMsgs addObject:chatMsg];
            }
        }
        else if ([dataJson isKindOfClass:[NSDictionary class]]) {
            CSKuleChatMsg* chatMsg = [CSKuleInterpreter decodeChatMsg:dataJson];
            [chatMsgs addObject:chatMsg];
        }
        
        [_chatingMsgList addObjectsFromArray:chatMsgs];
        [self.tableview reloadData];
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"获取信息中..."];
    [gApp.engine reqGetChatingMsgsOfKindergarten:gApp.engine.loginInfo.schoolId
                                            from:fromId
                                              to:toId
                                            most:most
                                         success:sucessHandler
                                         failure:failureHandler];
}

- (CGSize)textSize:(NSString*)text {
    CGSize sz = CGSizeZero;
    return sz;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.chatingEditor"]) {
        CSKuleChatingEditorViewController* destCtrl = segue.destinationViewController;
        destCtrl.delegate = self;
    }
}

#pragma mark - CSKuleChatingEditorViewControllerDelegate
- (void)willSendMsgWithText:(NSString *)msgBody {
    [self doSendText:msgBody];
}

@end

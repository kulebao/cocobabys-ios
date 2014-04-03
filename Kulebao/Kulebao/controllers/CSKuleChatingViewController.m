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
    self.tableview.backgroundColor = [UIColor clearColor];
    
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleChatingTableCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CSKuleChatingTableCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImageView* imgBubbleBg = [[UIImageView alloc] initWithFrame:CGRectNull];
        imgBubbleBg.tag = 100;
        [cell.contentView addSubview:imgBubbleBg];
        
        UILabel* labMsgBody = [[UILabel alloc] initWithFrame:CGRectNull];
        labMsgBody.tag = 101;
        labMsgBody.numberOfLines = 0;
        labMsgBody.font = [UIFont systemFontOfSize:14];
        labMsgBody.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:labMsgBody];

        UIImageView* imgMsgBody = [[UIImageView alloc] initWithFrame:CGRectNull];
        imgMsgBody.tag = 102;
        [cell.contentView addSubview:imgMsgBody];
        
        UIImageView* imgPortrait = [[UIImageView alloc] initWithFrame:CGRectNull];
        imgPortrait.tag = 103;
        imgPortrait.layer.cornerRadius = 4.0;
        imgPortrait.clipsToBounds = YES;
        [cell.contentView addSubview:imgPortrait];
        
        UILabel* labMsgTimestamp = [[UILabel alloc] initWithFrame:CGRectNull];
        labMsgTimestamp.tag = 104;
        labMsgTimestamp.numberOfLines = 1;
        labMsgTimestamp.font = [UIFont systemFontOfSize:11];
        labMsgTimestamp.backgroundColor = [UIColor clearColor];
        labMsgTimestamp.textAlignment = NSTextAlignmentCenter;
        labMsgTimestamp.textColor = [UIColor grayColor];
        [cell.contentView addSubview:labMsgTimestamp];
        
        UILabel* labMsgSender = [[UILabel alloc] initWithFrame:CGRectNull];
        labMsgSender.tag = 105;
        labMsgSender.numberOfLines = 1;
        labMsgSender.font = [UIFont systemFontOfSize:10];
        labMsgSender.backgroundColor = [UIColor clearColor];
        labMsgSender.textAlignment = NSTextAlignmentCenter;
        labMsgSender.textColor = UIColorRGB(0xCC, 0x66, 0x33);;
        [cell.contentView addSubview:labMsgSender];
    }
    
    UIImageView* imgBubbleBg = (UIImageView*)[cell.contentView viewWithTag:100];
    UILabel* labMsgBody = (UILabel*)[cell.contentView viewWithTag:101];
    UIImageView* imgMsgBody = (UIImageView*)[cell.contentView viewWithTag:102];
    UIImageView* imgPortrait = (UIImageView*)[cell.contentView viewWithTag:103];
    UILabel* labMsgTimestamp = (UILabel*)[cell.contentView viewWithTag:104];
    UILabel* labMsgSender = (UILabel*)[cell.contentView viewWithTag:105];
    
    CSKuleChatMsg* msg = [_chatingMsgList objectAtIndex:indexPath.row];
    CGSize msgBodySize = [self textSize:msg.content];
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:msg.timestamp] isoDateTimeString];
    labMsgTimestamp.frame = CGRectMake(40, 0, 320-40-40, 12);
//    if (indexPath.row % 3 == 0) {
        labMsgTimestamp.text = timestampString;
//    }
//    else {
//        labMsgTimestamp.text = nil;
//    }
    
    
    if (msg.sender.length > 0) {
        // From
        imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.png"];
        imgPortrait.frame = CGRectMake(2, 12, 32, 32);
        
        UIImage* bgImage = [UIImage imageNamed:@"msg-bg-from.png"];
        imgBubbleBg.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 15, 10, 10)];

        labMsgSender.text = msg.sender;
        labMsgSender.frame = CGRectMake(0, 46, 36, 12);
        
        if (msg.image.length > 0) {
            imgBubbleBg.frame = CGRectMake(36, 12, 90, 78);
            imgMsgBody.frame = CGRectMake(52, 18, 64, 64);
            labMsgBody.frame = CGRectNull;
            labMsgBody.text = nil;

            NSURL* qiniuImgUrl = [gApp.engine urlFromPath:msg.image];
            qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/128/h/128"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:qiniuImgUrl];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            [imgMsgBody setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:nil
                                       failure:nil];
        }
        else {
            imgBubbleBg.frame = CGRectMake(36, 12, msgBodySize.width + 30, msgBodySize.height+14);
            
            imgMsgBody.frame = CGRectNull;
            imgMsgBody.image = nil;
            
            labMsgBody.text = msg.content;
            labMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x + 16, 18, msgBodySize.width, msgBodySize.height);
        }
    }
    else {
        // To
        CSKuleChildInfo* childInfo = gApp.engine.currentRelationship.child;
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:childInfo.portrait];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/64/h/64"];
        [imgPortrait setImageWithURL:qiniuImgUrl placeholderImage:[UIImage imageNamed:@"chat_head_icon.png"]];
        
        
        imgPortrait.frame = CGRectMake(320-2-32-2, 12, 32, 32);
        
        UIImage* bgImage = [UIImage imageNamed:@"msg-bg-to.png"];
        imgBubbleBg.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 15)];
        
        labMsgSender.text = @"我";
        labMsgSender.frame = CGRectMake(320-2-32-4, 46, 36, 12);
        
        if (msg.image.length > 0) {
            imgBubbleBg.frame =  CGRectMake(320-36-90, 12, 90, 78);
            imgMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x+10, 18, 64, 64);
            labMsgBody.frame = CGRectNull;
            labMsgBody.text = nil;
            
            NSURL* qiniuImgUrl = [gApp.engine urlFromPath:msg.image];
            qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/128/h/128"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:qiniuImgUrl];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            [imgMsgBody setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:nil
                                       failure:nil];
        }
        else {
            imgBubbleBg.frame = CGRectMake(320-36-msgBodySize.width-30, 12, msgBodySize.width + 30, msgBodySize.height+14);
            
            imgMsgBody.frame = CGRectNull;
            imgMsgBody.image = nil;
            
            labMsgBody.text = msg.content;
            labMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x + 12, 18, msgBodySize.width, msgBodySize.height);
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleChatMsg* msg = [_chatingMsgList objectAtIndex:indexPath.row];
    CGFloat height = 0.0;
    if (msg.image.length > 0) {
        height = 95;
    }
    else {
        CGSize sz = [self textSize:msg.content];
        height = sz.height + 35;
        height = MAX(height, 60);
    }
    
    return height;
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
        
        [_chatingMsgList addObjectsFromArray:chatMsgs];
        [_tableview reloadData];
        
        if (_chatingMsgList.count > 0) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_chatingMsgList.count-1
                                                        inSection:0];
            [_tableview scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
        }
        
        [gApp alert:@"发送成功 ^_^"];
        [self.navigationController popToViewController:self animated:YES];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    
    long long retrieveFrom = -1;
    CSKuleChatMsg* msg = [_chatingMsgList lastObject];
    if (msg) {
        retrieveFrom = msg.msgId;
    }
    
    [gApp waitingAlert:@"发送中..."];
    [gApp.engine reqSendChatingMsgs:msgBody
                          withImage:imgUrl
                     toKindergarten:gApp.engine.loginInfo.schoolId
                       retrieveFrom:retrieveFrom
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
    CGSize sz = CGSizeMake(200.0, 999.0);
    CGSize textSz = [text sizeWithFont:[UIFont systemFontOfSize:14.0]
                     constrainedToSize:sz];
    
    textSz.width = MAX(textSz.width, 32);
    textSz.height = MAX(textSz.height, 32);
    
    return textSz;
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

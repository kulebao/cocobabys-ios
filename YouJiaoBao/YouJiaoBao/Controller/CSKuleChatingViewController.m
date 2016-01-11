//
//  CSKuleChatingViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingViewController.h"
#import "PullTableView.h"
#import "CSAppDelegate.h"
#import "CSKuleChatingEditorViewController.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"
#import "CSKuleChatingTableCell.h"
#import "TSFileCache.h"
#import "NSString+XHMD5.h"
#import "CSKuleURLDownloader.h"
#import "EntityTopicMsgHelper.h"
#import "EntityTopicMsgSenderHelper.h"
#import "NSDate+CSKit.h"
#import "NSURL+CSKit.h"
#import "CSEngine.h"
#import "CSHttpClient.h"
#import "EntityChildInfoHelper.h"

@interface CSKuleChatingViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CSKuleChatingEditorViewControllerDelegate, AVAudioPlayerDelegate> {
    UIImagePickerController* _imgPicker;
    NSMutableArray* _topicMsgList;
    
    AVAudioPlayer* _audioPlayer;
    
    TSFileCache* _voiceCache;
    
    CSKuleChatingTableCell* _denyDeleteCell;
    
    NSMutableSet* _senderIdSet;
}

@property (weak, nonatomic) IBOutlet PullTableView *tableview;
@property (nonatomic, strong) EntityTopicMsg* playingMsg;

- (IBAction)onBtnEditorClicked:(id)sender;
- (IBAction)onBtnCameraClicked:(id)sender;
- (IBAction)onBtnPhotosClicked:(id)sender;

@end

@implementation CSKuleChatingViewController
@synthesize playingMsg = _playingMsg;
@synthesize childInfo = _childInfo;

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
    //[self customizeBackBarItem];
    
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    _voiceCache = [TSFileCache cacheForURL:[NSURL fileURLWithPath:cachesDirectory isDirectory:YES]];
    [_voiceCache prepare:nil];
    [TSFileCache setSharedInstance:_voiceCache];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.pullDelegate = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    self.tableview.backgroundColor = [UIColor clearColor];
    
    _topicMsgList = [NSMutableArray array];
    
    _senderIdSet  = [NSMutableSet set];
    
    [self doReloadTopicMsgsFrom:-1
                             to:-1
                           most:20
                        success:^{
                            if (_topicMsgList.count > 0) {
                                [self.tableview scrollToRowAtIndexPath:[NSIndexPath
                                                                        indexPathForItem:(_topicMsgList.count-1) inSection:0]
                                                      atScrollPosition:UITableViewScrollPositionBottom
                                                              animated:NO];
                            }
                        } failure:^{
                            
                        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topicMsgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleChatingTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleChatingTableCell"];
    const CGFloat kWidth = tableView.bounds.size.width;
    
    if (cell == nil) {
        cell = [[CSKuleChatingTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"CSKuleChatingTableCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImageView* imgBubbleBg = [[UIImageView alloc] initWithFrame:CGRectNull];
        imgBubbleBg.tag = 100;
        [cell.contentView addSubview:imgBubbleBg];
        imgBubbleBg.userInteractionEnabled = YES;
        [imgBubbleBg addGestureRecognizer:cell.longPressGes];
        [imgBubbleBg addGestureRecognizer:cell.tapGes];
        
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
        
        UIImageView* voiceMsgBody = [[UIImageView alloc] initWithFrame:CGRectNull];
        voiceMsgBody.tag = 106;
        [cell.contentView addSubview:voiceMsgBody];
        voiceMsgBody.animationDuration = 0.7;
        
        UILabel* labAudioDuration = [[UILabel alloc] initWithFrame:CGRectNull];
        labAudioDuration.tag = 107;
        [cell.contentView addSubview:labAudioDuration];
        labAudioDuration.backgroundColor = [UIColor clearColor];
        labAudioDuration.textColor = [UIColor grayColor];
        labAudioDuration.font = [UIFont systemFontOfSize:12.0];
    
        cell.delegate = self;
    }
    
    UIImageView* imgBubbleBg = (UIImageView*)[cell.contentView viewWithTag:100];
    UILabel* labMsgBody = (UILabel*)[cell.contentView viewWithTag:101];
    UIImageView* imgMsgBody = (UIImageView*)[cell.contentView viewWithTag:102];
    UIImageView* imgPortrait = (UIImageView*)[cell.contentView viewWithTag:103];
    UILabel* labMsgTimestamp = (UILabel*)[cell.contentView viewWithTag:104];
    UILabel* labMsgSender = (UILabel*)[cell.contentView viewWithTag:105];
    UIImageView* voiceMsgBody = (UIImageView*)[cell.contentView viewWithTag:106];
    UILabel* labAudioDuration = (UILabel*)[cell.contentView viewWithTag:107];
    
    EntityTopicMsg* msg = [_topicMsgList objectAtIndex:indexPath.row];
    cell.msg = msg;
    
    CGSize msgBodySize = [CSKuleChatingTableCell textSize:msg.content];
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:(msg.timestamp.longLongValue)/1000.0] isoDateTimeString];
    labMsgTimestamp.frame = CGRectMake(40, 0, kWidth-40-40, 12);
    labMsgTimestamp.text = timestampString;
    
    labMsgBody.frame = CGRectNull;
    labMsgBody.text = nil;
    
    imgMsgBody.frame = CGRectNull;
    imgMsgBody.image = nil;
    
    voiceMsgBody.frame = CGRectNull;
    voiceMsgBody.image = nil;
    labAudioDuration.text = nil;
    
    if (![msg.senderType isEqualToString:@"t"]) {
        // To
        labMsgSender.text = nil;
        imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.png"];
        
        imgPortrait.frame = CGRectMake(2, 24, 32, 32);
        
        UIImage* bgImage = [UIImage imageNamed:@"chating_left_1.png"];
        imgBubbleBg.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 10, 10)];

        labMsgSender.frame = CGRectMake(45, 12, 136, 12);
        labMsgSender.textAlignment = NSTextAlignmentLeft;
        
        if (msg.mediaUrl.length > 0) {
            if ([msg.mediaType isEqualToString:@"voice"]) {
                imgBubbleBg.frame = CGRectMake(36, 12+12, 60, 48);
                voiceMsgBody.frame = CGRectMake(52, 18+12, 32, 32);
                
                voiceMsgBody.image = [UIImage imageNamed:@"playing_3.png"];
                
                voiceMsgBody.animationImages = @[[UIImage imageNamed:@"playing_1.png"],
                                                 [UIImage imageNamed:@"playing_2.png"],
                                                 [UIImage imageNamed:@"playing_3.png"]];
                
                NSError* error = nil;
                NSData* waveData = [_voiceCache dataForKey:msg.mediaUrl.MD5Hash];
                AVAudioPlayer* aPlayer = [[AVAudioPlayer alloc] initWithData:waveData error:&error];
                if (error == nil) {
                    labAudioDuration.text = [NSString stringWithFormat:@"%.0f'", aPlayer.duration];
                    [labAudioDuration sizeToFit];
                    CGRect audioLabelFrame = labAudioDuration.frame;
                    labAudioDuration.frame = CGRectMake(CGRectGetMaxX(voiceMsgBody.frame) + 14, imgBubbleBg.frame.origin.y, audioLabelFrame.size.width, audioLabelFrame.size.height);
                }
                else {
                    NSLog(@"error :%@", error);
                }
            }
            else {
                imgBubbleBg.frame = CGRectMake(36, 12+12, 90, 78);
                imgMsgBody.frame = CGRectMake(52, 18+12, 64, 64);
            }
        }
        else {
            imgBubbleBg.frame = CGRectMake(36, 12+12, msgBodySize.width + 30, msgBodySize.height+14);
            
            labMsgBody.text = msg.content;
            labMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x + 16, 18+12, msgBodySize.width, msgBodySize.height);
        }
    }
    else {
        // From
        imgPortrait.frame = CGRectMake(kWidth-2-32-2, 24, 32, 32);
        
        UIImage* bgImage = [UIImage imageNamed:@"chating_right_1.png"];
        imgBubbleBg.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 10, 15)];

        labMsgSender.frame = CGRectMake(kWidth-2-132-4-45, 12, 136, 12);
        labMsgSender.textAlignment = NSTextAlignmentRight;
        
        if (msg.mediaUrl.length > 0) {
            if ([msg.mediaType isEqualToString:@"voice"]) {
                
                imgBubbleBg.frame =  CGRectMake(kWidth-36-90+30, 12+12, 60, 48);
                voiceMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x+10, 18+12, 32, 32);
                
                voiceMsgBody.image = [UIImage imageNamed:@"voice_right_1.png"];
                voiceMsgBody.animationImages = @[[UIImage imageNamed:@"voice_right_3.png"],
                                                 [UIImage imageNamed:@"voice_right_2.png"],
                                                 [UIImage imageNamed:@"voice_right_1.png"]];
                
                NSError* error = nil;
                NSData* waveData = [_voiceCache dataForKey:msg.mediaUrl.MD5Hash];
                AVAudioPlayer* aPlayer = [[AVAudioPlayer alloc] initWithData:waveData error:&error];
                if (error == nil) {
                    labAudioDuration.text = [NSString stringWithFormat:@"%.0f'", aPlayer.duration];
                    [labAudioDuration sizeToFit];
                    CGRect audioLabelFrame = labAudioDuration.frame;
                    labAudioDuration.frame = CGRectMake(imgBubbleBg.frame.origin.x-audioLabelFrame.size.width-4, imgBubbleBg.frame.origin.y, audioLabelFrame.size.width, audioLabelFrame.size.height);
                }
                else {
                    NSLog(@"error :%@", error);
                }
            }
            else {
                imgBubbleBg.frame =  CGRectMake(kWidth-36-90-15, 12+12, 90, 78);
                imgMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x+10, 18+12, 64, 64);
            }
        }
        else {
            imgBubbleBg.frame = CGRectMake(kWidth-36-msgBodySize.width-30, 12+12, msgBodySize.width + 30, msgBodySize.height+14);
            
            labMsgBody.text = msg.content;
            labMsgBody.frame = CGRectMake(imgBubbleBg.frame.origin.x + 12, 18+12, msgBodySize.width, msgBodySize.height);
        }
    }
    
    // msg with picture.
    if (msg.mediaUrl.length > 0) {
        if ([msg.mediaType isEqualToString:@"voice"]) {
            
        }
        else {
            NSURL* qiniuImgUrl = [NSURL URLWithString:msg.mediaUrl];
            [imgMsgBody sd_setImageWithURL:qiniuImgUrl
                          placeholderImage:[UIImage imageNamed:@"img-placeholder.png"]];

        }
    }
    
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    NSURL* qiniuImgUrl = nil;
    NSString* senderName = nil;
    
    EntityTopicMsgSender* senderInfo = [EntityTopicMsgSenderHelper queryEntityWithUid:msg.senderId];
    if (senderInfo) {
        senderName = senderInfo.name;
        if ([msg.senderId isEqualToString:engine.loginInfo.uid]) {
            senderName = @"我";
        }
        
        if (senderInfo.portrait.length > 0) {
            qiniuImgUrl = [NSURL URLWithString:senderInfo.portrait];
            qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/64/h/64"];
        }
    }
    else {
        // Get Sender avatar and name.
        if (![_senderIdSet containsObject:msg.senderId]) {
            [_senderIdSet addObject:msg.senderId];
            CSLog(@"++ %@", msg.senderId);
            [http opGetTopicMsgSender:msg.senderId
                               ofType:msg.senderType
                       inKindergarten:engine.loginInfo.schoolId.integerValue
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [EntityTopicMsgSenderHelper updateEntities:@[responseObject]];
                                  [_senderIdSet removeObject:msg.senderId];
                                  CSLog(@"-- %@", msg.senderId);
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [_senderIdSet removeObject:msg.senderId];
                                  CSLog(@"-- %@", msg.senderId);
                              }];
        }
        else {
            CSLog(@"== %@", msg.senderId);
        }
    }
    
    if(qiniuImgUrl) {
        [imgPortrait sd_setImageWithURL:qiniuImgUrl placeholderImage:[UIImage imageNamed:@"chat_head_icon.png"] options:SDWebImageRetryFailed|SDWebImageRefreshCached|SDWebImageAllowInvalidSSLCertificates];
    }
    else {
        imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.png"];
    }
    
    if (senderName.length == 0) {
        if ([msg.senderType isEqualToString:@"t"]) {
            senderName = @"教师";
        }
        else {
            senderName = @"家长";
        }
    }
    labMsgSender.text = senderName;
    
    // Check if show the timestamp
    NSInteger row = indexPath.row;
    if (row > 0) {
        EntityTopicMsg* preMsg = [_topicMsgList objectAtIndex:(row-1)];
        if ([msg.senderId isEqualToString:preMsg.senderId]
            && ABS(msg.timestamp.longLongValue - preMsg.timestamp.longLongValue)<180*1000 ) {
                labMsgTimestamp.hidden = YES;
        }
        else  {
            labMsgTimestamp.hidden = NO;
        }
    }
    else {
        labMsgTimestamp.hidden = NO;
    }
    
    
    if ([self.playingMsg isEqual:msg]) {
        [voiceMsgBody startAnimating];
    }
    else {
        [voiceMsgBody stopAnimating];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    EntityTopicMsg* msg = [_topicMsgList objectAtIndex:indexPath.row];
    if (msg.read.integerValue == 0) {
        [EntityTopicMsgHelper markAsRead:msg];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntityTopicMsg* msg = [_topicMsgList objectAtIndex:indexPath.row];
    CGFloat height = [CSKuleChatingTableCell calcHeightForMsg:msg];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
/*
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
//        [UIPasteboard generalPasteboard].string = [data objectAtIndex:indexPath.row];
    }
}
 */

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [self performSelector:@selector(loadHistoryMsgs)
               withObject:nil
               afterDelay:3.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    [self performSelector:@selector(loadNewMsgs)
               withObject:nil
               afterDelay:.0f];
}

- (void)loadHistoryMsgs {
    NSInteger most = 20;
    long long toId = 1;
    
    EntityTopicMsg* topicMsg = [_topicMsgList firstObject];
    if (topicMsg) {
        toId = topicMsg.uid.longLongValue;
    }
    
    long long fromId = toId - most;
    fromId = fromId > 0 ? fromId : 0;

    [self doReloadTopicMsgsFrom:fromId
                             to:toId
                           most:most
                        success:^{
                            self.tableview.pullTableIsRefreshing = NO;
                            EntityTopicMsg* firstTopicMsg = [_topicMsgList firstObject];
                            if ([firstTopicMsg isEqual:topicMsg]) {
                                [gApp alert:@"没有历史消息"];
                            }
                            
                        } failure:^{
                            self.tableview.pullTableIsRefreshing = NO;
                        }];
}

- (void)loadNewMsgs{
    NSInteger most = 20;
    long long fromId = 0;
    
    EntityTopicMsg* topicMsg = [_topicMsgList lastObject];
    if (topicMsg) {
        fromId = topicMsg.uid.longLongValue;
    }
    
    long long toId = fromId + most;
    
    [self doReloadTopicMsgsFrom:fromId to:toId most:most success:^{
        self.tableview.pullTableIsLoadingMore = NO;
        EntityTopicMsg* lastTopicMsg = [_topicMsgList lastObject];
        if ([lastTopicMsg isEqual:topicMsg]) {
            [gApp alert:@"没有新消息"];
        }
    } failure:^{
        self.tableview.pullTableIsLoadingMore = NO;
    }];
}


#pragma mark - UI Actions
- (IBAction)onBtnEditorClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.chating.editor" sender:nil];
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
    CSEngine* engine = [CSEngine sharedInstance];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
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
                             engine.loginInfo.schoolId,
                             engine.loginInfo.phone,
                             @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* imgUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, imgFileName];
        [self doSendPicture:imgUrl];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传图片中"];
    
    [http opUploadToQiniu:imgData
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
    [self doSendMsg:nil withMediaUrl:imgUrl ofType:@"image"];
}

- (void)doSendText:(NSString*)msgBody {
    [self doSendMsg:msgBody withMediaUrl:nil ofType:nil];
}

- (void)doSendVoice:(NSString*)voiceUrl {
    [self doSendMsg:nil withMediaUrl:voiceUrl ofType:@"voice"];
}

- (void)doSendMsg:(NSString*)msgBody withMediaUrl:(NSString*)mediaUrl ofType:(NSString*)mediaType {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* topicMsgs = [NSMutableArray array];
        
        EntityTopicMsg* lastMsg = [_topicMsgList lastObject];
        
        NSNumber* oldTimestamp = lastMsg.timestamp;
        NSNumber* timestamp = oldTimestamp;
        
//        if ([dataJson isKindOfClass:[NSArray class]]) {
//            for (id topicMsgJson in dataJson) {
//                EntityTopicMsg* topicMsg = [CSKuleInterpreter decodeTopicMsg:topicMsgJson];
//                [topicMsgs addObject:topicMsg];
//                
//                if (timestamp < topicMsg.timestamp) {
//                    timestamp = topicMsg.timestamp;
//                }
//            }
//        }
//        else if ([dataJson isKindOfClass:[NSDictionary class]]) {
//            EntityTopicMsg* topicMsg = [CSKuleInterpreter decodeTopicMsg:dataJson];
//            [topicMsgs addObject:topicMsg];
//            
//            if (timestamp < topicMsg.timestamp) {
//                timestamp = topicMsg.timestamp;
//            }
//        }
//        
//        if (oldTimestamp < timestamp) {
//            [gApp.engine.preferences setTimestamp:timestamp
//                                         ofModule:kKuleModuleChating
//                                         forChild:currentChild.childId];
//        }
//        
        [_topicMsgList addObjectsFromArray:topicMsgs];
        [_tableview reloadData];
        
        if (_topicMsgList.count > 0) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_topicMsgList.count-1
                                                        inSection:0];
            [_tableview scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
        }
        
        [gApp alert:@"发送成功 ^_^"];
        [self.navigationController popToViewController:self animated:YES];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    long long retrieveFrom = -1;
    EntityTopicMsg* msg = [_topicMsgList lastObject];
    if (msg) {
        retrieveFrom = msg.uid.longLongValue;
    }
    
    CSEngine* engine = [CSEngine sharedInstance];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    [gApp waitingAlert:@"发送中..."];
    [http opSendTopicMsg:msgBody
              withSender:engine.loginInfo
            withMediaUrl:mediaUrl
             ofMediaType:mediaType
                 ofChild:self.childInfo.childId
          inKindergarten:engine.loginInfo.schoolId.integerValue
            retrieveFrom:retrieveFrom
                 success:sucessHandler
                 failure:failureHandler];
}

- (void)doReloadTopicMsgsFrom:(long long)fromId
                           to:(long long)toId
                         most:(NSInteger)most
                      success:(void (^)(void))success
                      failure:(void (^)(void))failure {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSArray* topicMsgs = nil;
        
        if ([dataJson isKindOfClass:[NSArray class]]) {
            topicMsgs = [EntityTopicMsgHelper updateEntities:dataJson];
        }
        else if ([dataJson isKindOfClass:[NSDictionary class]]) {
            topicMsgs = [EntityTopicMsgHelper updateEntities:@[dataJson]];
        }
        
        if (topicMsgs) {
            [_topicMsgList addObjectsFromArray:topicMsgs];
        }
        
        /*
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleChating forChild:currentChild.childId];
        NSTimeInterval timestamp = oldTimestamp;
        
        if ([dataJson isKindOfClass:[NSArray class]]) {
            for (id topicMsgJson in dataJson) {
                EntityTopicMsg* topicMsg = [CSKuleInterpreter decodeTopicMsg:topicMsgJson];
                [self downloadVoice:topicMsg];
                [topicMsgs addObject:topicMsg];
                
                if (timestamp < topicMsg.timestamp) {
                    timestamp = topicMsg.timestamp;
                }
            }
        }
        else if ([dataJson isKindOfClass:[NSDictionary class]]) {
            EntityTopicMsg* topicMsg = [CSKuleInterpreter decodeTopicMsg:dataJson];
            [self downloadVoice:topicMsg];
            [topicMsgs addObject:topicMsg];
            if (timestamp < topicMsg.timestamp) {
                timestamp = topicMsg.timestamp;
            }
        }
        
        if (oldTimestamp < timestamp) {
            [gApp.engine.preferences setTimestamp:timestamp
                                         ofModule:kKuleModuleChating
                                         forChild:currentChild.childId];
        }
        
        [_topicMsgList addObjectsFromArray:topicMsgs];
        [_topicMsgList sortUsingComparator:^NSComparisonResult(EntityTopicMsg* obj1, EntityTopicMsg* obj2) {
            NSComparisonResult ret = NSOrderedSame;
            if (obj1.msgId < obj2.msgId) {
                ret = NSOrderedAscending;
            }
            else if (obj1.msgId > obj2.msgId) {
                ret = NSOrderedDescending;
            }
            
            return ret;
        }];
         
         if (success) {
         success();
         }
        */
        
        [_topicMsgList sortUsingComparator:^NSComparisonResult(EntityTopicMsg* obj1, EntityTopicMsg* obj2) {
            NSComparisonResult ret = NSOrderedSame;
            if (obj1.uid.longLongValue < obj2.uid.longLongValue) {
                ret = NSOrderedAscending;
            }
            else if (obj1.uid.longLongValue > obj2.uid.longLongValue) {
                ret = NSOrderedDescending;
            }
            
            return ret;
        }];
        
        [gApp hideAlert];
        [self.tableview reloadData];
        
        if (success) {
            success();
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
        if (failure) {
            failure();
        }
    };
    
    CSEngine* engine = [CSEngine sharedInstance];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    [gApp waitingAlert:@"获取信息中..."];
    [http opGetTopicMsgsOfChild:self.childInfo.childId
                 inKindergarten:engine.loginInfo.schoolId.integerValue
                           from:fromId
                             to:toId
                           most:most
                        success:sucessHandler
                        failure:failureHandler];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.chating.editor"]) {
        CSKuleChatingEditorViewController* destCtrl = segue.destinationViewController;
        destCtrl.delegate = self;
    }
}

#pragma mark - CSKuleChatingEditorViewControllerDelegate
- (void)willSendMsgWithText:(NSString *)msgBody {
    [self doSendText:msgBody];
}

- (void)willSendMsgWithVoice:(NSData *)amrData {
    CSEngine* engine = [CSEngine sharedInstance];
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    NSString* voiceFileName = [NSString stringWithFormat:@"chat_voice/%@/%@/%@.amr",
                             engine.loginInfo.schoolId,
                             engine.loginInfo.phone,
                             @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* voiceUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, voiceFileName];
        NSData* waveData = DecodeAMRToWAVE(amrData);
        [_voiceCache storeData:waveData forKey:voiceUrl.MD5Hash];
        [self doSendVoice:voiceUrl];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传语音中"];
    [http opUploadToQiniu:amrData
                  withKey:voiceFileName
                 withMime:@"image/jpeg"
                  success:sucessHandler
                  failure:failureHandler];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSMutableSet* updateIndexPaths = [NSMutableSet set];
    
    if (self.playingMsg != nil) {
        NSUInteger index = [_topicMsgList indexOfObject:self.playingMsg];
        if (index != NSNotFound) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        
        self.playingMsg = nil;
        [self.tableview reloadRowsAtIndexPaths:[updateIndexPaths allObjects]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSMutableSet* updateIndexPaths = [NSMutableSet set];
    
    if (self.playingMsg != nil) {
        NSUInteger index = [_topicMsgList indexOfObject:self.playingMsg];
        if (index != NSNotFound) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        
        self.playingMsg = nil;
        [self.tableview reloadRowsAtIndexPaths:[updateIndexPaths allObjects]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - PlayingMsg 
- (void)setPlayingMsg:(EntityTopicMsg *)playingMsg {
    _playingMsg = playingMsg;
    
}

- (void)downloadVoice:(EntityTopicMsg*)msg {
    if (msg.mediaUrl.length > 0 && [msg.mediaType isEqualToString:@"voice"]) {
        if (![_voiceCache existsDataForKey:msg.mediaUrl.MD5Hash]) {
            CSKuleURLDownloader* dn = [CSKuleURLDownloader URLDownloader:[NSURL URLWithString:msg.mediaUrl]];
            [dn start];
        }
    }
}

#pragma mark - CSKuleChatingTableCellDelegate
- (void)chatingTableCell:(CSKuleChatingTableCell*)cell playVoice:(EntityTopicMsg*)msg {
    if ([msg.mediaType isEqualToString:@"voice"]) {
        NSIndexPath* indexPath = [self.tableview indexPathForCell:cell];
        NSMutableSet* updateIndexPaths = [NSMutableSet set];
        
        BOOL theSame = [msg isEqual:self.playingMsg];
        
        if (self.playingMsg != nil) {
            NSUInteger index = [_topicMsgList indexOfObject:self.playingMsg];
            if (index != NSNotFound) {
                [updateIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            }
            _audioPlayer.delegate = nil;
            [_audioPlayer stop];
            
            self.playingMsg = nil;
        }
        
        if (!theSame) {
            self.playingMsg = msg;
            
            if (self.playingMsg != nil) {
                NSData* waveData = [_voiceCache dataForKey:msg.mediaUrl.MD5Hash];
                if (waveData == nil) {
                    NSURL* voiceUrl = [NSURL URLWithString:msg.mediaUrl];
                    NSData* amrData = [NSData dataWithContentsOfURL:voiceUrl];
                    
                    waveData = DecodeAMRToWAVE(amrData);
                    [_voiceCache storeData:waveData forKey:msg.mediaUrl.MD5Hash];
                }
                
                NSError* error = nil;
                _audioPlayer = [[AVAudioPlayer alloc] initWithData:waveData error:&error];
                _audioPlayer.volume = 1.0;
                if (error) {
                    CSLog(@"ERROR: %@", error);
                }
                else {
                    _audioPlayer.delegate = self;
                    [_audioPlayer play];
                }
            }
        }
        
        [updateIndexPaths addObject:indexPath];
        [self.tableview reloadRowsAtIndexPaths:[updateIndexPaths allObjects]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)chatingTableCellDidLongPress:(CSKuleChatingTableCell*)cell {
    _denyDeleteCell = cell;
    UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteCell:)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:flag, nil]];
    [menu setTargetRect:cell.frame inView:cell.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (void)deleteCell:(id)sender {
    if (_denyDeleteCell) {
        NSIndexPath* indexPath = [self.tableview indexPathForCell:_denyDeleteCell];
        if (indexPath) {
            EntityTopicMsg*msg = [_topicMsgList objectAtIndex:indexPath.row];
            
            if ([msg isEqual:_playingMsg]) {
                [_audioPlayer stop];
                _audioPlayer.delegate = nil;
                _playingMsg = nil;
            }
        
            SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
                NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
                NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
                if (error_code == 0) {
                    [_topicMsgList removeObject:msg];
                    [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [gApp hideAlert];
                }
                else {
                    [gApp alert:error_msg];
                }
            };
            
            FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
                CSLog(@"failure:%@", error);
                [gApp hideAlert];
            };
            
            
            CSEngine* engine = [CSEngine sharedInstance];
            CSHttpClient* http = [CSHttpClient sharedInstance];
            
            [gApp waitingAlert:@"请稍等"];
            [http opDeleteTopicMsgs:msg.uid.longLongValue
                            ofChild:msg.childInfo.childId
                     inKindergarten:engine.loginInfo.schoolId.integerValue
                            success:sucessHandler
                            failure:failureHandler];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end

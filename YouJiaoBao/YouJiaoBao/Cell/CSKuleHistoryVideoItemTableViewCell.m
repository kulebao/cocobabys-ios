//
//  CSKuleHistoryVideoItemTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 15/3/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryVideoItemTableViewCell.h"
#import "CSAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+CSKit.h"
#import "EGOCache.h"
#import "BDMultiDownloader.h"
#import "MBProgressHUD.h"
#import <UIAlertView+BlocksKit.h>
#import "UIImageView+WebCache.h"
#import "CSEngine.h"
#import "AFNetworkReachabilityManager.h"
#import "CBSessionDataModel.h"

@interface CSKuleHistoryVideoItemTableViewCell() {
    NSURL* _videoURL;
    NSString* _shareToken;
}

@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UIView *viewVideoContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
- (IBAction)onBtnPlayClicked:(id)sender;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem* playerItem;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGes;

@property (nonatomic, strong) MBProgressHUD* hub;

@end

@implementation CSKuleHistoryVideoItemTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.imgPortrait.layer.cornerRadius = 4.0;
    self.imgPortrait.clipsToBounds = YES;
    self.btnPlay.userInteractionEnabled = NO;
    self.btnShare.hidden = YES;
    
    self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self addGestureRecognizer:self.longPressGes];
    
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.viewVideoContainer addGestureRecognizer:self.tapGes];
    [self.tapGes requireGestureRecognizerToFail:self.longPressGes];
    
    self.viewVideoContainer.backgroundColor = [UIColor blackColor];
    self.viewVideoContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewVideoContainer.layer.borderWidth = 1;
    self.viewVideoContainer.layer.cornerRadius = 4.0;
    self.viewVideoContainer.clipsToBounds = YES;
    
//    self.hub = [[MBProgressHUD alloc] initWithView:self];
//    self.hub.mode = MBProgressHUDModeAnnularDeterminate;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHistoryInfo:(CBHistoryInfo *)historyInfo {
    _historyInfo = historyInfo;
    
    //if ([_historyInfo.sender.senderId isEqualToString:gApp.engine.currentRelationship.parent.parentId]) {
    if (NO) {
        self.longPressGes.enabled = YES;
    }
    else {
        self.longPressGes.enabled = NO;
    }
    
    [self updateUI];
}

+ (CGFloat)calcHeight:(CBHistoryInfo*)historyInfo width:(CGFloat)width{
    
    CGFloat yy = 51;
    //CGFloat xx = 70;
    
    const CGFloat kFixedWidth = width-64-8;
    
    CGSize sz = [historyInfo.content sizeWithFont:[UIFont systemFontOfSize:14.0]
                                constrainedToSize:CGSizeMake(kFixedWidth, 9999)];
    if (historyInfo.content.length > 0) {
        yy += sz.height + 4 + 4 + 4;
    }
    else {
        yy += sz.height;
    }
    yy += 128; // video
    //yy += 24; // share button

    return yy;
}

- (void)updateUI {
    CBSenderInfo* senderInfo = _historyInfo.sender;
    
    self.labName.text = senderInfo.type;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:_historyInfo.timestamp.doubleValue/1000];
    self.labDate.text = [fmt stringFromDate:timestamp];

    _videoURL = nil;
    self.playerItem = nil;

    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    CBMediaInfo* media = _historyInfo.medium.firstObject;
    self.labContent.text = _historyInfo.content;
    
    //检查视频是否已经下载
    NSString* videoKey = media.url.MD5HashEx;
    EGOCache* cache = [EGOCache globalCache];
    BOOL localExist = NO;
    
    self.viewVideoContainer.backgroundColor = [UIColor blackColor];
    self.viewVideoContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewVideoContainer.layer.borderWidth = 1;
    self.viewVideoContainer.layer.cornerRadius = 4.0;
    self.viewVideoContainer.clipsToBounds = YES;
    
    if (media.url.length > 0) {
        localExist = [cache hasCacheForKey:videoKey];
        if (localExist) {
            _videoURL = [cache localURLForKey:videoKey];
        }
        else {
            _videoURL = [NSURL URLWithString:media.url];
        }
    }
    
    if (_videoURL && _videoURL.fileURL) {
        self.playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.viewVideoContainer.layer addSublayer:self.playerLayer];
        self.playerLayer.frame = self.viewVideoContainer.layer.bounds;
        self.viewVideoContainer.backgroundColor = [UIColor clearColor];
        self.viewVideoContainer.layer.borderWidth = 0;
        self.viewVideoContainer.layer.cornerRadius = 0.0;
        self.viewVideoContainer.clipsToBounds = YES;
    }
    
    self.btnPlay.alpha = 1.0f;
    
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    [self.imgPortrait sd_setImageWithURL:[NSURL URLWithString:session.loginInfo.portrait]
                        placeholderImage:[UIImage imageNamed:@"chat_head_icon.gif"]];
    self.labName.text = session.loginInfo.name;
}

- (void)onLongPress:(UILongPressGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (ges.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(historyVideoItemTableCellDidLongPress:)]) {
            [_delegate historyVideoItemTableCellDidLongPress:self];
        }
    }
}

- (void)onTap:(UITapGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [ges locationInView:self.viewVideoContainer];
        if(CGRectContainsPoint(self.viewVideoContainer.bounds, point)) {
            if (_videoURL && _videoURL.fileURL) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti.video"
                                                                    object:_videoURL];
            }
            else if (_videoURL) {
                if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
                    [self performSelector:@selector(startDownloader) withObject:nil];
                }
                else {
                    [self queryToDownload];
                }
            }
        }
    }
}

- (IBAction)onBtnPlayClicked:(id)sender {
    if (self.player) {
        self.btnPlay.alpha = 0.0f;
        [_playerItem seekToTime:kCMTimeZero];
        [self.player play];
    }
}

- (void)queryToDownload {
    NSString *title = @"提示";
    NSString *message = @"是否下载视频？建议在Wifi下进行下载。";
    
    UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:title message:message];
    
    [alert bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [alert bk_addButtonWithTitle:@"确定" handler:^{
        [self performSelector:@selector(startDownloader) withObject:nil];
    }];
    
    [alert show];
}

- (void)startDownloader {
    CSLog(@"Start download task of video at %@", _videoURL);
    if (_videoURL) {
        [gApp waitingAlert:@"下载中"];
        [[BDMultiDownloader shared] queueURLRequest:[NSURLRequest requestWithURL:_videoURL] completion:^(NSData* data) {
            if (data) {
                CSLog(@"Downloaded video at %@. Cacheing", _videoURL);
                [[EGOCache globalCache] setData:data forKey:_videoURL.absoluteString.MD5HashEx completion:^(BOOL ok) {
                    CSLog(@"Cached video as key %@", _videoURL.absoluteString.MD5HashEx);
                    [self performSelectorOnMainThread:@selector(downloadFinished) withObject:nil waitUntilDone:YES];
                }];
            }
        }];
    }
}

- (void)downloadFinished {
    [gApp hideAlert];
    [self updateUI];
}

#pragma mark - PlayEndNotification
- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    if ((AVPlayerItem *)notification.object != _playerItem) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self stop];
    }];
}

- (void)stop {
    [self.player pause];
    [_playerItem seekToTime:kCMTimeZero];
    self.btnPlay.alpha = 1.0f;
    [self setNeedsDisplay];
}

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                                    actualTime:NULL
                                                         error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

#pragma mark - Share
- (IBAction)onBtnShareClicked:(id)sender {
    
}

@end

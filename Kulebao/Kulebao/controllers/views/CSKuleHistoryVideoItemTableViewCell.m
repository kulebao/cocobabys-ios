//
//  CSKuleHistoryVideoItemTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 15/3/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryVideoItemTableViewCell.h"
#import "CSAppDelegate.h"
#import "EntitySenderInfoHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "CSKuleURLDownloader.h"
#import "TSFileCache.h"
#import "NSString+CSKit.h"
#import "NSString+XHMD5.h"

@interface CSKuleHistoryVideoItemTableViewCell() {
    NSURL* _videoURL;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UIView *viewVideoContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
- (IBAction)onBtnPlayClicked:(id)sender;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem* playerItem;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGes;

@end

@implementation CSKuleHistoryVideoItemTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.viewVideoContainer.backgroundColor = [UIColor clearColor];
    self.imgPortrait.layer.cornerRadius = 4.0;
    self.imgPortrait.clipsToBounds = YES;
    self.btnPlay.userInteractionEnabled = NO;
    
    self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self addGestureRecognizer:self.longPressGes];
    
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.viewVideoContainer addGestureRecognizer:self.tapGes];
    [self.tapGes requireGestureRecognizerToFail:self.longPressGes];
    
    self.viewVideoContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewVideoContainer.layer.borderWidth = 1;
    self.viewVideoContainer.layer.cornerRadius = 4.0;
    self.viewVideoContainer.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHistoryInfo:(EntityHistoryInfo *)historyInfo {
    _historyInfo = historyInfo;
    
    if ([_historyInfo.sender.senderId isEqualToString:gApp.engine.currentRelationship.parent.parentId]) {
        self.longPressGes.enabled = YES;
    }
    else {
        self.longPressGes.enabled = NO;
    }
    
    [self updateUI];
}

+ (CGFloat)calcHeight:(EntityHistoryInfo*)historyInfo {
    return 200;
}

- (void)updateUI {
    EntitySenderInfo* senderInfo = (EntitySenderInfo*)_historyInfo.sender;
    
    self.labName.text = senderInfo.type;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:_historyInfo.timestamp.doubleValue/1000];
    self.labDate.text = [fmt stringFromDate:timestamp];
    
    CSKuleMediaInfo* media = _historyInfo.medium.firstObject;
    
    if (self.player) {
        [self.player pause];
    }

#if 1
    TSFileCache* fileCache = [TSFileCache sharedInstance];
    
    if (![fileCache existsDataForKey:media.url.MD5HashEx]) {
        _videoURL = [NSURL URLWithString:media.url];
        self.playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
        
        CSKuleURLDownloader* dn = [CSKuleURLDownloader videoURLDownloader:[NSURL URLWithString:media.url]];
        [dn start];
    }
    else {
        _videoURL = [fileCache localURLForKey:media.url.MD5HashEx];
        self.playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
        
        if (self.playerItem.status == AVPlayerItemStatusFailed) {
            _videoURL = [NSURL URLWithString:media.url];
            self.playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
            
            CSKuleURLDownloader* dn = [CSKuleURLDownloader videoURLDownloader:[NSURL URLWithString:media.url]];
            [dn start];
        }
    }
#else
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:media.url]];
#endif
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
   
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.viewVideoContainer.layer addSublayer:self.playerLayer];
    self.playerLayer.frame = self.viewVideoContainer.layer.bounds;
    
    self.btnPlay.alpha = 1.0f;
    
    // Get Sender avatar and name.
    CSKuleSenderInfo* sender = [CSKuleSenderInfo new];
    sender.type = senderInfo.type;
    sender.senderId = senderInfo.senderId;
    
    [gApp.engine reqGetSenderProfileOfKindergarten:gApp.engine.loginInfo.schoolId
                                        withSender:sender
                                          complete:^(id obj) {
                                              NSURL* qiniuImgUrl = nil;
                                              NSString* senderName = nil;
                                              if ([obj isKindOfClass:[CSKuleEmployeeInfo class]]) {
                                                  CSKuleEmployeeInfo* employeeInfo = obj;
                                                  if (employeeInfo.portrait.length > 0) {
                                                      qiniuImgUrl = [gApp.engine urlFromPath:employeeInfo.portrait];
                                                  }
                                                  
                                                  senderName = employeeInfo.name;
                                              }
                                              else if ([obj isKindOfClass:[CSKuleParentInfo class]]) {
                                                  CSKuleParentInfo* parentInfo = obj;
                                                  if (parentInfo.portrait.length > 0) {
                                                      qiniuImgUrl = [gApp.engine urlFromPath:parentInfo.portrait];
                                                  }
                                                  else {
                                                      qiniuImgUrl = [gApp.engine urlFromPath:gApp.engine.currentRelationship.child.portrait];
                                                  }
                                                  
                                                  if ([sender.senderId isEqualToString:gApp.engine.currentRelationship.parent.parentId]) {
                                                      senderName = @"我";
                                                  }
                                                  else {
                                                      senderName = parentInfo.name;
                                                  }
                                              }
                                              
                                              if (qiniuImgUrl) {
                                                  qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/64/h/64"];
                                                  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:qiniuImgUrl];
                                                  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
                                                  request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                                                  [self.imgPortrait setImageWithURLRequest:request
                                                                          placeholderImage:[UIImage imageNamed:@"chat_head_icon.png"]
                                                                                   success:nil
                                                                                   failure:nil];
                                              }
                                              else {
                                                  self.imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.png"];
                                              }
                                              
                                              self.labName.text = senderName;
                                          }];
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
        if(CGRectContainsPoint(self.viewVideoContainer.bounds, point)
           && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            if (self.player && self.btnPlay.alpha > 0) {
                self.btnPlay.alpha = 0.0f;
                [_playerItem seekToTime:kCMTimeZero];
                [self.player play];
            }
            else if (self.player && _videoURL) {
                CSLog(@"open full screen.");
                [self stop];
//
//                CSKuleMediaInfo* media = _historyInfo.medium.firstObject;
//                TSFileCache* fileCache = [TSFileCache sharedInstance];
//                NSURL* videoURL = [fileCache localURLForKey:media.url.MD5HashEx];
//                videoURL = [NSURL URLWithString:media.url];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti.video"
                                                                    object:_videoURL];
            }
        }
        else if (self.playerItem.status == AVPlayerItemStatusFailed) {
            CSKuleMediaInfo* media = _historyInfo.medium.firstObject;
            _videoURL = [NSURL URLWithString:media.url];
            self.playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
            
            CSKuleURLDownloader* dn = [CSKuleURLDownloader videoURLDownloader:[NSURL URLWithString:media.url]];
            [dn start];
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

@end

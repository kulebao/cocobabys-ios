//
//  CSVideoView.m
//  youlebao
//
//  Created by xin.c.wang on 15/3/18.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSVideoView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface CSVideoView()

@property (nonatomic, strong) AVPlayer* _avplayer;
@property (nonatomic, readonly) AVPlayerLayer* _avplayerLayer;

@property (nonatomic, strong) AVPlayerItem* avplayerItem;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGes;

@end

@implementation CSVideoView
@synthesize avplayerItem = _avplayerItem;
@synthesize videoURL = _videoURL;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        
        [self addGestureRecognizer:self.tapGes];
    }
    
    return self;
}

- (AVPlayerLayer*)_avplayerLayer {
    return (AVPlayerLayer*)self.layer;
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    _avplayerItem = [AVPlayerItem playerItemWithURL:videoURL];
    
    self._avplayer = [[AVPlayer alloc] initWithPlayerItem:self.avplayerItem];
    self._avplayerLayer.player = self._avplayer;
    [self._avplayer play];
}

- (void)onTap:(UITapGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [ges locationInView:self];
        if(CGRectContainsPoint(self.bounds, point)) {
        }
    }
}

@end

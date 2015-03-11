//
//  CaptureViewController.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-12.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SBCaptureDefine.h"
#import "SBVideoRecorder.h"

@interface CaptureViewController : UIViewController <SBVideoRecorderDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id delegate;

@end

@protocol CaptureViewControllerDelegate <NSObject>

//recorder完成视频的合成
- (void)captureViewController:(CaptureViewController *)ctrl didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL;

@end

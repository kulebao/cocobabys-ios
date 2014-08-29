//
//  HMPlayerView.h
//  HM_Demo
//
//  Created by Zouwanli on 5/30/14.
//  Copyright (c) 2014 邹万里. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"
#import "CSAppDelegate.h"
#import "NSCyscleBuffer.h"
#import "HMAudioPlayer.h"
#import "HMAudioRecorder.h"
//#import "HMVideoPlayerDelegate.h"
#import "HMAudioRecorderDelegate.h"

@class HMAudioPlayer;
@class HMAudioRecorder;
@interface HMPlayerView : UIViewController<HMAudioRecorderDelegate,HMVideoPlayerDelegate>
{
    
    node_handle                    my_node;
    video_handle                   video_h;               //视频句柄
    audio_handle                   audio_h;               //音频句柄
    talk_handle                    talk_h;                //对讲句柄
//    alarm_handle                   alerm_h;               //报警句柄
    
    
    video_codec_handle             localVideoHandle;
    audio_codec_handle             localAudioHandel;
    local_record_handle            localRecordHandel;
    
    P_OPEN_VIDEO_RES               Video_res;
    P_OPEN_AUDIO_RES               Audio_res;
    P_DEVICE_INFO                  devInfo;
    
    user_id                        myID;
    CODE_STREAM                    myCodeStream;
    
    NSCycleBuffer*                 videoBuffer;
    
    HMAudioPlayer*                 audioPlyaer;
    HMAudioRecorder*               audioRecorder;
    
    
    IBOutlet UIView*               PaintView;
    
    IBOutlet UIButton *btnSpeak;
    
    IBOutlet UIButton *btnSpeakStop;
    
    IBOutlet UIButton *btnListen;
    IBOutlet UIButton *btnListenStop;
    
    IBOutlet UIView *navBar;
    
    __weak IBOutlet UILabel *labTitle;
    
    __weak IBOutlet UIControl      *CoverView;
    
    NSLock                         *videoLock;
    NSLock                         *audioLock;
    NSLock                         *talkLock;
    
    BOOL 						   IsRunning;
}

@property (nonatomic) BOOL IsRunning;

//@property (strong, nonatomic) NSLock*           talkLock;
@property (strong, nonatomic) NSLock*           videoLock;
//@property (strong, nonatomic) NSLock*           audioLock;


- (void)addObjcTOVideoDataArray:(char*)data Len:(NSInteger)len;
- (void)addObjcTOAudioDataArray:(char*)data Len:(NSInteger)len;

- (void)ConnectVideoBynode:(node_handle)node;
- (void)setNavTitle:(NSString *)title;

- (void)DirectConnectVideo:(NSArray*)array;

- (IBAction)btnSpeakAction:(id)sender;
- (IBAction)btnSpeakStopAction:(id)sender;
- (IBAction)btnListenAction:(id)sender;
- (IBAction)btnListenStopAction:(id)sender;


@end

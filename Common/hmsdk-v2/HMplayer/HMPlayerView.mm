//
//  HMPlayerView.m
//  HM_Demo
//
//  Created by Zouwanli on 5/30/14.
//  Copyright (c) 2014 邹万里. All rights reserved.
//

#import "HMPlayerView.h"
#import "CSAppDelegate.h"

#define video_data   0
#define audio_data   1

@interface HMPlayerView () {
}
@end

@implementation HMPlayerView
@synthesize IsRunning;
@synthesize videoLock = _videoLick;

NSArray* videoDataArr = nil;
NSArray* audioDataArr = nil;

BOOL controlBarHidden = NO;

#pragma mark -
#pragma mark 接收到视频数据回调函数
static void data_callback(user_data data, P_FRAME_DATA frame, hm_result result)
{
    NSArray* dataArray = (__bridge NSArray*)(data);
    HMPlayerView* playerView = [dataArray objectAtIndex:0];
    if (result == HMEC_OK)
    {
        int data_type = [(NSNumber*)[dataArray objectAtIndex:1] intValue];
        //录像写入文件
        //        [playerView writeRecordToIphone:(pchar)(frame->frame_stream) Len:frame->frame_len Type:&(frame->frame_info)];
        
        switch (data_type) {
            case video_data:
            {
//                [playerView.videoLock lock];
                [playerView addObjcTOVideoDataArray:(pchar)(frame->frame_stream) Len:frame->frame_len];
//                [playerView.videoLock unlock];
                
            } break;
            case audio_data:
            {
                [playerView addObjcTOAudioDataArray:(pchar)frame->frame_stream Len:frame->frame_len];
            } break;
            default: break;
        }
        
    }
    else
    {
        /* 网络异常 */
        //        NSLog(@"result=%x,视频数据异常,frame=%x",result,frame);
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //播放视频时候，隐藏tabBar
        self.hidesBottomBarWhenPushed = YES;
        labTitle.text = nil;
        
        localVideoHandle = 0;
        localAudioHandel = 0;
        
        videoLock = [[NSLock alloc] init];
        audioLock = [[NSLock alloc] init];
        talkLock  = [[NSLock alloc] init];
        
        Video_res = (P_OPEN_VIDEO_RES)malloc(sizeof(OPEN_VIDEO_RES));
        Audio_res = (P_OPEN_AUDIO_RES)malloc(sizeof(OPEN_AUDIO_RES));
        devInfo   = (P_DEVICE_INFO)malloc(sizeof(DEVICE_INFO));
        
        videoDataArr = [[NSArray alloc] initWithObjects:self,[[NSNumber alloc] initWithInt:video_data], nil];
        audioDataArr = [[NSArray alloc] initWithObjects:self,[[NSNumber alloc] initWithInt:audio_data], nil];
        
       // [self setWantsFullScreenLayout: YES]; //设置这个属性为YES可以解决状态栏半透明带来的view位移问题
    }
    return self;
}

- (void)dealloc {
    if (Video_res) {
        free(Video_res);
    }
    
    if (Audio_res) {
        free(Audio_res);
    }
    
    if (devInfo) {
        free(devInfo);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customizeBackBarItem];

    ((PaintingView*)PaintView).videoPlayerDelegate = self;
    
    controlBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation:UIStatusBarAnimationSlide];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchCentralArea)];
    [self.view addGestureRecognizer:tap];
    
    _autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                        target:self
                                                      selector:@selector(onTimer:)
                                                      userInfo:nil
                                                       repeats:NO];
    
//    [btnListen setEnabled:YES];
//    [btnListenStop setEnabled:NO];
    
    btnListen.hidden = NO;
    btnListenStop.hidden = YES;
    
    rightBar.hidden = !IsRunning;
    
    labTrailTips.hidden = !self.isTrail;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    gApp.isPlayView = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    gApp.isPlayView = NO;
    
    [self performSelectorInBackground:@selector(CloseAllForLogOutDev) withObject:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

// Returns interface orientation masks.
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ConnectVideoBynode:(node_handle)node
{
    my_node = node;
    
    NSString* name;
    cpchar cpname;
    hm_server_get_node_name(my_node,&cpname);
    if (cpname == NULL) name = @"NULL";
    else name = [[NSString alloc] initWithUTF8String:cpname];
    [self setTitle:name];
    
    [self performSelectorInBackground:@selector(HandConnectVideBynode) withObject:nil];
}

- (void)setNavTitle:(NSString *)title {
    labTitle.text = title;
}

- (void)HandConnectVideBynode
{
    if(my_node == NULL)
        return;
    
    CONNECT_INFO connectInfo;
    connectInfo.cm = CM_DEF;
    connectInfo.cp = CPI_DEF;
    connectInfo.ct = CT_MOBILE;
    
    hm_result result = hm_pu_login_ex(my_node, &connectInfo, &myID);
    
    if (result == HMEC_OK)
    {
        
        if (localVideoHandle == NULL) {
            hm_video_init(HME_VE_H264, &localVideoHandle);  // 视频解码器初始化
        }
        
        OPEN_VIDEO_PARAM videoParam = {};
        videoParam.channel = 0;
        videoParam.data    =  (__bridge void*)(videoDataArr);  //(void*)video_data;
        videoParam.cb_data = &data_callback;
        videoParam.cs_type = HME_CS_MAJOR;  //设置为主，次码流;
        videoParam.vs_type = HME_VS_REAL;
        
        if ( hm_pu_open_video(myID,&videoParam, &video_h) == HMEC_OK)   //开启视频
        {
            if (videoBuffer == NULL) {
                videoBuffer = [[NSCycleBuffer alloc] initWithCapacity:kVIDEO_DATA_BUFFER_MAXLENGTH*1.5 bytesPerBuffer:kVIDEO_DATA_BUFFER_BYTES];
            }
            
            if ( hm_pu_start_video(video_h,Video_res)== HMEC_OK)  //请求视频数据
            {
                if ( hm_pu_get_device_info(myID, devInfo) != HMEC_OK)
                {
                    if (devInfo) {
                        free(devInfo);
                    }
                    devInfo = nil;
                }
                else
                {
                    //初始化音频解码器
                    if (localAudioHandel == NULL) hm_audio_init(devInfo->channel_capacity[0]->audio_code_type, &localAudioHandel);
                }
                
                [CoverView setHidden:YES];
                
                IsRunning = YES;
                rightBar.hidden = !IsRunning;
                NSInvocationOperation* operationDisplay = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(HMRundisplayThread) object:nil];
                NSOperationQueue* queue = [[NSOperationQueue alloc] init];
                [queue addOperation:operationDisplay];
                //[queue release];
                
            }
            else
            {
                NSString* message= @"请求视频数据失败";
                [self performSelectorOnMainThread:@selector(ConnectFailShowMessage:) withObject:message waitUntilDone:YES];
                NSLog(@"请求视频数据失败");
            }
        }
        else
        {
            NSString* message= @"开启视频失败";
            [self performSelectorOnMainThread:@selector(ConnectFailShowMessage:) withObject:message waitUntilDone:YES];
            NSLog(@"开启视频失败");
        }
    }
    else
    {
        NSString* message= @"连接视频失败";
        [self performSelectorOnMainThread:@selector(ConnectFailShowMessage:) withObject:message waitUntilDone:YES];
        NSLog(@"连接视频失败 result=0x%X", result);
    }
}

- (void)DirectConnectVideo:(NSArray*)array
{
    [self performSelectorInBackground:@selector(HandDirectConnectVide:) withObject:array];
}

- (void)HandDirectConnectVide:(NSArray*)array
{
    pchar ip,sn,username,pass;
    int32 port = 0;
    ip         = (pchar)[[array objectAtIndex:0] UTF8String];
    port       = [[array objectAtIndex:1] integerValue];
    sn         = (pchar)[[array objectAtIndex:2] UTF8String];
    username   = (pchar)[[array objectAtIndex:3] UTF8String];
    pass       = (pchar)[[array objectAtIndex:4] UTF8String];
    
    
    
    if (hm_pu_login(ip, port, sn, username, pass, CT_MOBILE, &myID)== HMEC_OK)
    {
        
        if (localVideoHandle == NULL)
        {
            hm_video_init(HME_VE_H264, &localVideoHandle);  // 视频解码器初始化
        }
        
        OPEN_VIDEO_PARAM videoParam = {};
        videoParam.channel = 0;
        videoParam.data    =  (__bridge void*)(videoDataArr);  //(void*)video_data;
        videoParam.cb_data = &data_callback;
        videoParam.cs_type = HME_CS_MAJOR;  //设置为主，次码流;
        videoParam.vs_type = HME_VS_REAL;
        
        if ( hm_pu_open_video(myID,&videoParam, &video_h) == HMEC_OK)   //开启视频
        {
            if (videoBuffer == NULL)
            {
                videoBuffer = [[NSCycleBuffer alloc] initWithCapacity:kVIDEO_DATA_BUFFER_MAXLENGTH*1.5 bytesPerBuffer:kVIDEO_DATA_BUFFER_BYTES];
            }
            
            if ( hm_pu_start_video(video_h,Video_res)== HMEC_OK)  //请求视频数据
            {
                
                if ( hm_pu_get_device_info(myID, devInfo) != HMEC_OK)
                {
                    if (devInfo) {
                        free(devInfo);
                    }
                    devInfo = nil;
                }
                else
                {
                    //初始化音频解码器
                    if (localAudioHandel == NULL) hm_audio_init(devInfo->channel_capacity[0]->audio_code_type, &localAudioHandel);
                }
                
                [self performSelectorOnMainThread:@selector(HiddenCoverView) withObject:nil waitUntilDone:NO];
                
                IsRunning = YES;
                rightBar.hidden = !IsRunning;
                NSInvocationOperation* operationDisplay = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(HMRundisplayThread) object:nil];
                NSOperationQueue* queue = [[NSOperationQueue alloc] init];
                [queue addOperation:operationDisplay];
                //[queue release];
                
            }
            else
            {
                NSString* message= @"请求视频失败";
                [self performSelectorOnMainThread:@selector(ConnectFailShowMessage:) withObject:message waitUntilDone:YES];
                NSLog(@"请求视频失败");
            }
        }
        else
        {
            NSString* message= @"连接失败";
            [self performSelectorOnMainThread:@selector(ConnectFailShowMessage:) withObject:message waitUntilDone:YES];
        }
    }
    else
    {
        NSString* message= @"连接失败";
        [self performSelectorOnMainThread:@selector(ConnectFailShowMessage:) withObject:message waitUntilDone:YES];
    }
}

- (void)HiddenCoverView
{
    [CoverView setHidden:YES];
}

#pragma mark - 连接失败提示
- (void)ConnectFailShowMessage:(NSString*)message
{
    [CoverView setHidden:YES];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    [alert show];
   // [alert release];
}



#pragma mark - 音视频数据放入队列函数

- (void)addObjcTOVideoDataArray:(char*)data Len:(NSInteger)len
{
    if (data!=nil && len>0) {
        [videoBuffer enqueue:data dataBytesSize:len];
    }
    
}

- (void)addObjcTOAudioDataArray:(char*)data Len:(NSInteger)len
{
    char* out_data = (char*)malloc(320);
    memset(out_data, 0, 320);
    int32 out_len = 320;
    if (hm_audio_decode(localAudioHandel, out_data, &out_len, data, len, 8000)== 0) {
        if (audioPlyaer) {
            [audioPlyaer enqueueData:(char*)out_data dataBytesSize:out_len];
        }
    }
    free(out_data);
}


#pragma mark -
#pragma mark 播放视频线程
- (void)HMRundisplayThread
{
    [[NSThread currentThread] setName: @"Run display thread"];
	NSInteger nLen;			//数据长度
    char* pdata = NULL;			//数据区
    
    if (localVideoHandle == NULL) return;
    while (IsRunning)
    {
        nLen = 0;
        [videoLock lock];
        pdata = (char*)[videoBuffer dequeue:&nLen];
        if (pdata == NULL) {
            [videoLock unlock];
            continue;
        }
        yuv_handle      yuv_h = NULL;
        hm_video_decode_yuv(localVideoHandle, (char*)pdata, nLen,&yuv_h);
        [videoLock unlock];
        if (yuv_h != NULL)
        {
            YUV_PICTURE yuv_pic ;
            hm_video_get_yuv_data(yuv_h, &yuv_pic);
            
            if ( PaintView != nil && IsRunning == YES)
            {
                [videoLock lock];
                [(PaintingView*)PaintView DisplayYUVdata:&yuv_pic];
                [videoLock unlock];
                [NSThread sleepForTimeInterval:0.01];  //优化播放线程
            }
        }
        if ( yuv_h != NULL) hm_video_release_yuv(yuv_h);
    }
    
    [videoLock lock];
    [(PaintingView*)PaintView erase]; // 清屏
    [videoLock unlock];
}


#pragma mark -  点击视频显示区域检测
- (void)touchArea:(NSInteger)direction
{
    
}

- (void)touchCentralArea
{
    if (_autoHiddenTimer) {
        [_autoHiddenTimer invalidate];
        _autoHiddenTimer = nil;
    }
    controlBarHidden = !controlBarHidden;
//	[[UIApplication sharedApplication] setStatusBarHidden: controlBarHidden withAnimation: UIStatusBarAnimationSlide];
//	[self.navigationController setNavigationBarHidden: controlBarHidden animated:YES];
    
    [self setNavHidden:controlBarHidden];
    [self setRightBarHidden:controlBarHidden];
    
    if(!controlBarHidden) {
        _autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                            target:self
                                                          selector:@selector(onTimer:)
                                                          userInfo:nil
                                                           repeats:NO];
    }
}

#pragma mark - 听说操作
- (IBAction)btnSpeakAction:(id)sender
{
    [btnSpeak setEnabled:NO];
    [btnSpeakStop setEnabled:YES];
    
    [self performSelectorInBackground:@selector(speakStartAction) withObject:nil];
}

- (IBAction)btnSpeakStopAction:(id)sender
{
    [btnSpeak setEnabled:YES];
    [btnSpeakStop setEnabled:NO];
    
    [self performSelectorInBackground:@selector(speakStopAction) withObject:nil];
}

- (void)speakStartAction
{
    if (talk_h != NULL || devInfo==nil)return;
    
    OPEN_TALK_PARAM param;
    param.channel = 0;  //dvs通道，如果不是dvs设置为0;
    param.audio_channel = devInfo->channel_capacity[0]->audio_channel;
    param.sample        = devInfo->channel_capacity[0]->audio_sample;
    param.audio_type    = devInfo->channel_capacity[0]->audio_code_type;
    
    if ( hm_pu_open_talk(myID, &param,&talk_h)  == HMEC_OK)
    {
        if ( hm_pu_start_talk(talk_h) == HMEC_OK)
        {
            NSLog(@"开始对讲===========》》》》》》");
            [talkLock lock];
            [self startTalk];   //开启对讲
            [talkLock unlock];
        }
    }
    else
    {
        NSLog(@"开启对讲失败===========》》》》》》");
    }
}

- (void)speakStopAction
{
    if (talk_h == NULL)return;
    //按钮按下再抬起之后响应此函数
    if (hm_pu_stop_talk(talk_h) == HMEC_OK)
    {
        [talkLock lock];
        [self stopTalk];    //停止对讲
        NSLog(@"停止对讲===========》》》》》》");
        [talkLock unlock];
    }
    
    hm_pu_close_talk(talk_h);
    talk_h = nil;
}



- (IBAction)btnListenAction:(id)sender
{
    if (self.isTrail) {
        [gApp shortAlert:@"演示视频，不允许打开声音"];
    }
    else {
        [self performSelectorInBackground:@selector(StartAudioPlayer) withObject:nil];
        btnListen.hidden = YES;
        btnListenStop.hidden = NO;
    }
}

- (IBAction)btnListenStopAction:(id)sender
{
    [self performSelectorInBackground:@selector(StopAudioPlayer) withObject:nil];
//    [btnListen setEnabled:YES];
//    [btnListenStop setEnabled:NO];
    btnListen.hidden = NO;
    btnListenStop.hidden = YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [gApp alert:error.localizedDescription];
    }
    else {
        [gApp alert:@"拍照成功，已存入您的相册"];
    }
}

- (IBAction)btnCaptureAction:(id)sender {
    if (self.isTrail) {
        [gApp shortAlert:@"演示视频，不允许拍照"];
    }
    else {
        UIImage *viewImage = [PaintView snapshotImage];
        UIImageWriteToSavedPhotosAlbum(viewImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)StartAudioPlayer
{
    if ( audio_h != NULL) return;
    
    OPEN_AUDIO_PARAM Aparam;
    Aparam.channel = 0;
    if (Audio_res) {
        free(Audio_res);
        Audio_res = NULL;
    }
    Audio_res = (P_OPEN_AUDIO_RES)malloc(sizeof(OPEN_AUDIO_RES));
    OPEN_AUDIO_PARAM Audioparam = {};
    Audioparam.data    =  (__bridge void*)(audioDataArr); //(void*)audio_data;
    Audioparam.cb_data = &data_callback;
    
    hm_result result = hm_pu_open_audio(myID, &Audioparam , Audio_res,&audio_h);
    if (result == HMEC_OK)
    {
        
        if (  hm_pu_start_audio(audio_h) == HMEC_OK)
        {
            //打开音频成功以后，初始化音频播放器
            NSInteger bitsPerChannel = 16;  //不管是speex还是pcm经过解码之后，都应该使用  16 值
            UInt32    fomat          = HME_AE_SPEEX;     //  值为0表示PCM，值为2表示SPEEX
            if(Audio_res->audio_type == HME_AE_PCMS8) fomat = HME_AE_PCMS8;
            
            if (audioPlyaer == NULL)
            {
                audioPlyaer = [[HMAudioPlayer alloc] initAudioPlayer:fomat bitsPerChannel:bitsPerChannel SampleRate:Audio_res->sample Channel:Audio_res->channel];
                int size = kAUDIO_DATA_BUFFER_MAXLENGTH;
                if (Audio_res->audio_type == HME_AE_PCMS8) size = kAUDIO_DATA_SIMULATE_LENGTH;
                [audioPlyaer startWithEmptyDataSize:size];
            }
            else [audioPlyaer start];
            
            
            
        }
        else
        {
            NSLog(@"开启音频失败");
        }
    }
    else
    {
        // 0x900102
        NSLog(@"开启音频失败");
    }
}

- (void)StopAudioPlayer
{
    if (audio_h == NULL) return;
    
    [audioPlyaer stop];
    hm_pu_stop_audio(audio_h);
    hm_pu_close_audio(audio_h);
    audio_h = NULL;
}

#pragma mark - 对讲控制函数

- (void)startTalk
{
    //开始录音器
    [audioLock lock];
    audioRecorder = [[HMAudioRecorder alloc] initAudioRecorder];
    [audioRecorder setAudioRecorderDelegate:self];
    [audioRecorder start];
    [audioLock unlock];
}

- (void)stopTalk
{
    [audioLock lock];
    if (audioRecorder!= nil) {
        [audioRecorder stop];
        //[audioRecorder release];
        audioRecorder = nil;
    }
    [audioLock unlock];
}


#pragma mark - 退出处理函数

- (void)CloseAllForLogOutDev
{
    NSLog(@"退出视频开始");
    IsRunning = NO;
    rightBar.hidden = !IsRunning;
    if (video_h != NULL) {
        hm_pu_stop_video(video_h);  //程序在出现网络异常的时候，切换视频通道，会卡死在此接口
        hm_pu_close_video(video_h);
        video_h = NULL;
    }
    
    sleep(1);
    
    if (videoBuffer != nil) {
        //[videoBuffer release];
        videoBuffer = nil;
    }
    
    if (localVideoHandle != NULL) {
        [videoLock lock];
        hm_video_uninit(localVideoHandle);
        localVideoHandle = NULL;
        [videoLock unlock];
    }
    
    if (localAudioHandel != NULL) {
        [audioLock lock];
        hm_audio_uninit(localAudioHandel);
        localAudioHandel = NULL;
        [audioLock unlock];
    }
    
    //关闭音频
    if (audio_h != NULL) {
        
        [audioPlyaer stop];
        [audioPlyaer resetAudioData];
        
        hm_pu_stop_audio(audio_h);
        hm_pu_close_audio(audio_h);
        audio_h = NULL;
    }
    
    //关闭对讲
    if (talk_h != NULL) {
        [talkLock lock];
        hm_pu_stop_talk(talk_h);
        hm_pu_close_talk(talk_h);
        talk_h = NULL;
        [talkLock unlock];
    }

    if (myID!= NULL) {
        hm_pu_logout(myID);
    }
    
}

#pragma mark - AudioRecorderDelegate 委托实现

//录音器回调
-(void)HMAudioQueueInputBufferingCallack:(AudioQueueRef)inAQ buffer:(char *)buffer startTime:(const AudioTimeStamp *)inStartTime numberPackets:(NSInteger)inNumPackets
{
    //编码音频数据,然后发送音频数据
    if(inNumPackets > 0 && buffer!=nil)
    {
        //编码音频数据
        const short* pBuffer = new short[160];
        int32  nlen = 160*sizeof(short);
        hm_result rlt = hm_audio_encode(localAudioHandel , (pointer)pBuffer,&nlen, buffer, inNumPackets, 8000);
        
        FRAME_DATA frameData ;
        frameData.frame_stream = pBuffer;
        frameData.frame_len    = nlen;
        if (rlt == 0) hm_pu_send_talk_data(talk_h, &frameData);  //发送音频数据
        delete [] pBuffer;
    }
}
- (IBAction)onBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setNavHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.4 animations:^{
        CATransform3D trans = CATransform3DIdentity;
        if (hidden) {
            trans = CATransform3DMakeTranslation(0, -70, 0);
        }
        
        navBar.layer.transform = trans;
    }];
}

- (void)setRightBarHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.4 animations:^{
        CATransform3D trans = CATransform3DIdentity;
        if (hidden) {
            trans = CATransform3DMakeTranslation(100, 0, 0);
        }
        
        rightBar.layer.transform = trans;
    }];
}

- (void)onTimer:(NSTimer*)timer {
    _autoHiddenTimer = nil;
    controlBarHidden = YES;
    [self setNavHidden:controlBarHidden];
    [self setRightBarHidden:controlBarHidden];
}

@end

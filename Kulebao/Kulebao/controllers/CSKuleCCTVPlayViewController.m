//
//  CSKuleCCTVPlayViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-13.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCCTVPlayViewController.h"
#import "hm_sdk.h"

video_codec_handle vchandle;

static void pCall (user_data data, P_FRAME_DATA frame, hm_result result) {
    CSLog(@"call back");
    
    CSKuleCCTVPlayViewController* player = (__bridge CSKuleCCTVPlayViewController*)data;
    
    if (vchandle == NULL) {
        hm_video_init(HME_VE_H264, &vchandle);
    }
    
    yuv_handle yuv_h = NULL;
    hm_result result1 = hm_video_decode_yuv(vchandle, (char*)frame->frame_stream, frame->frame_len, &yuv_h);
    
    if (yuv_h != NULL) {
        YUV_PICTURE yuv_pic ;
        hm_video_get_yuv_data(yuv_h, &yuv_pic);
        
        hm_video_release_yuv(yuv_h);
    }
}

@interface CSKuleCCTVPlayViewController () {
    user_id _userId;
    DEVICE_INFO _deviceInfo;
    node_handle _nodeHandle;
    video_handle _videoHandle;
    OPEN_VIDEO_RES _openVideoRes;
    video_codec_handle _videoCodecHandle;
    
    BOOL _running;
}

@end

@implementation CSKuleCCTVPlayViewController
@synthesize deviceMeta = _deviceMeta;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    self.delegate = self;
    
    self.navigationItem.title = _deviceMeta[@"name"];
    _nodeHandle = [_deviceMeta[@"node_handle"] pointerValue];
    
    CONNECT_INFO connectInfo;
    connectInfo.cm = CM_DEF;
    connectInfo.cp = CPI_DEF;
    connectInfo.ct = CT_MOBILE;
    
    hm_pu_login_ex(_nodeHandle, &connectInfo, &_userId);
    
    hm_video_init(HME_VE_H264, &_videoCodecHandle);
    
    hm_pu_get_device_info(_userId, &_deviceInfo);
    
    //
    OPEN_VIDEO_PARAM param;
    param.channel = 0;
    param.cs_type = HME_CS_MAJOR;
    param.vs_type = HME_VS_REAL;
    param.cb_data = &pCall;
    param.data = (__bridge user_data)(self);
    //
    hm_pu_open_video(_userId, &param, &_videoHandle);
    //
    hm_pu_start_video(_videoHandle, &_openVideoRes);
    
    NSInvocationOperation* operationDisplay = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(HMRundisplayThread) object:nil];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operationDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    gLResize(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)dealloc {
    _running = NO;
    
    if (_videoHandle != NULL) {
        hm_pu_stop_video(_videoHandle);
        hm_pu_close_video(_videoHandle);
        _videoHandle = NULL;
    }
    
    if (_videoCodecHandle != NULL) {
        hm_video_uninit(_videoCodecHandle);
        _videoCodecHandle = NULL;
    }
    
    if (_userId != NULL) {
        hm_pu_logout(_userId);
        _userId = NULL;
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    renderFrame();
    gLRender();
}

#pragma mark - GLKViewControllerDelegate
- (void)glkViewControllerUpdate:(GLKViewController *)controller {

    gLInit();
}

#pragma mark 播放视频线程
- (void)HMRundisplayThread
{
    [[NSThread currentThread] setName: @"Run display thread"];
	int           	nLen;                   //数据长度
	const char		*pdata = NULL;			//数据区
    
    if (_videoCodecHandle == NULL) return;
    while (_running)
    {
        nLen = 1000;
        char pdata[nLen] ;
        yuv_handle      yuv_h = NULL;
        hm_video_decode_yuv(_videoCodecHandle, (char*)pdata, nLen, &yuv_h);
        if (yuv_h != NULL)
        {
            YUV_PICTURE yuv_pic ;
            hm_video_get_yuv_data(yuv_h, &yuv_pic);
            
//            if ( PaintView != nil && IsRunning == YES)
//            {
//                [videoLock lock];
//                [(PaintingView*)PaintView DisplayYUVdata:&yuv_pic];
//                [videoLock unlock];
//                [NSThread sleepForTimeInterval:0.01];  //优化播放线程
//            }
        }
        if ( yuv_h != NULL) hm_video_release_yuv(yuv_h);
    }
    
//    [videoLock lock];
//    [(PaintingView*)PaintView erase]; // 清屏
//    [videoLock unlock];
}

@end

//
//  CSKuleCCTVPlayViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-13.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCCTVPlayViewController.h"
#import "hm_sdk.h"

void pCall (user_data data, P_FRAME_DATA frame, hm_result result) {
    CSLog(@"call back");
}


@implementation CSKuleCCTVPlayViewController
@synthesize deviceInfo = _deviceInfo;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    self.delegate = self;
    
    self.navigationItem.title = _deviceInfo[@"name"];
    node_handle node = [_deviceInfo[@"node_handle"] pointerValue];
    
    user_id userId;
    hm_pu_login_ex(node, &userId);
    
    DEVICE_INFO deviceInfo;
    hm_pu_get_device_info(userId, &deviceInfo);
    
    //
    OPEN_VIDEO_PARAM param;
    param.channel = 0;
    param.cs_type = HME_CS_MAJOR;
    param.vs_type = HME_VS_REAL;
    param.cb_data = &pCall;
    //
    video_handle videohandle = NULL;
    hm_pu_open_video(userId, &param, &videohandle);
    //
    OPEN_VIDEO_RES res;
    hm_pu_start_video(videohandle, &res);
    
    gLInit();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    gLResize(self.view.bounds.size.width, self.view.bounds.size.height);
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

    gLRender();
}

#pragma mark - GLKViewControllerDelegate
- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    renderFrame();
}

@end

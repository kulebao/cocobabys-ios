//
//  PaintingView.h
//  HM_server_demo
//
//  Created by 邹 万里 on 13-7-23.
//  Copyright (c) 2013年 邹 万里. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "hm_sdk.h"
#import "define.h"
//#import "HMVideoPlayerDelegate.h"

@protocol HMVideoPlayerDelegate

@required

//发送云台控制命令
- (void)touchArea:(NSInteger)direction;

//点击屏幕中央区域
- (void)touchCentralArea;

@end



typedef enum  {
	DisplayModeFullScreen,			//全屏模式
	DisplayModeOrigin,				//原始画面大小模式
	DisplayModeDefault = DisplayModeFullScreen,			//默认图像模式
} DisplayMode;

@interface PaintingView : UIView
{
@private
    
    // The pixel dimensions of the backbuffer
	GLint		backingWidth;
	GLint		backingHeight;
    
    EAGLContext                    *Mcontext;
    
    
    GLuint		viewRenderbuffer, viewFramebuffer;

    NSLock		 *_drawLock;
    
    //中央点击区域的大小
    CGRect centalTouchRect;

}

@property (assign) id<HMVideoPlayerDelegate> videoPlayerDelegate;

- (void)DisplayYUVdata:(P_YUV_PICTURE)yuv_pic;

- (void)erase;    //清屏
@end

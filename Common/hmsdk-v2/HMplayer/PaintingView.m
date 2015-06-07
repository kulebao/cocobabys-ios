//
//  PaintingView.m
//  HM_server_demo
//
//  Created by 邹 万里 on 13-7-23.
//  Copyright (c) 2013年 邹 万里. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <sys/sysctl.h>
#import <sys/types.h>
#import "PaintingView.h"

@implementation PaintingView {
    uint32	picture_width;		//	图像宽度
	uint32	picture_height;		//	图像高度
}

@synthesize videoPlayerDelegate;


// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	
	//CGFloat width = 320.0;
	//CGFloat height = 480.0;
    
    if ((self = [super initWithCoder:aDecoder]))
    {
        _drawLock = [[NSLock alloc] init];
		
		
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		Mcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		if (!Mcontext || ![EAGLContext setCurrentContext:Mcontext]) {
			[self release];
			return nil;
		}
        
        //中央点击区域
        CGRect boundsRect = self.bounds;
        centalTouchRect.size.width = boundsRect.size.width / 3;
        centalTouchRect.size.height = boundsRect.size.height / 3;
        centalTouchRect.origin.x = (boundsRect.size.width - centalTouchRect.size.width) / 2;
        centalTouchRect.origin.y = (boundsRect.size.height - centalTouchRect.size.height) / 2;
        
        //UIScreen* mainscr = [UIScreen mainScreen];
        //width = mainscr.currentMode.size.width;
        //height = mainscr.currentMode.size.height;
        
        gLInit();
        [self layoutSubviews];
    }
    return self;
}


// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
    CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
    
    gLResize(width,height);    //初始化屏幕大小
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.contentsScale = 1;  //设置缩放参数
    
	[EAGLContext setCurrentContext: Mcontext];
	[self destroyFramebuffer];
	[self createFramebuffer];
}

- (BOOL)createFramebuffer
{
	[_drawLock lock];
	
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[Mcontext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
	//NSLog(@"backingWidth: %d,backingHeight: %d", backingWidth, backingHeight);
	
	[_drawLock unlock];
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		//NSLog(@"GL ERROR: failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	[_drawLock lock];
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	[_drawLock unlock];
}

- (void) dealloc
{
	if([EAGLContext currentContext] == Mcontext)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
    gLUninit();
	[_drawLock lock];
	
	[super dealloc];
}


- (void) erase
{
	[_drawLock lock];
	
	[EAGLContext setCurrentContext:Mcontext];
	
	//Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    glClearColor(0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
	
	//Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[Mcontext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
	[_drawLock unlock];
}


- (void)DisplayYUVdata:(P_YUV_PICTURE)yuv_pic;
{
    if (yuv_pic->ydata == NULL || yuv_pic->udata == NULL || yuv_pic->vdata == NULL) return;
    
    picture_width = yuv_pic->width;
    picture_height = yuv_pic->height;
    
    setFrameBuffer(yuv_pic->ydata, yuv_pic->udata, yuv_pic->vdata, yuv_pic->ystripe, yuv_pic->ustripe, yuv_pic->ustripe, yuv_pic->width, yuv_pic->height);
    
    [EAGLContext setCurrentContext:Mcontext];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    gLRender();
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[Mcontext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}


//获取所在矩形的索引号，矩形索引号如下：
// 0  1  2
//
// 3  4  5
//
// 6  7  8
//
- (NSInteger) getPointInRect: (CGPoint)point
{
    CGSize boundSize = self.bounds.size;
    
	int index_x, index_y;
	
	if(point.x <= 0.1 || point.x > boundSize.width)
		index_x = -1;
	else if(point.x < centalTouchRect.origin.x)
		index_x = 0;
	else if(point.x > (centalTouchRect.origin.x + centalTouchRect.size.width))
		index_x = 2;
	else
		index_x = 1;
	
	if(point.y <= 0.1 || point.y > boundSize.height)
		index_y = -1;
	else if(point.y < centalTouchRect.origin.y)
		index_y = 0;
	else if(point.y > (centalTouchRect.origin.y + centalTouchRect.size.height))
		index_y = 2;
	else
		index_y = 1;
	
	return index_x + index_y * 3;
}


- (void)touchArea:(NSInteger)direction
{
	[videoPlayerDelegate touchArea:direction];
}


#pragma mark -
#pragma mark 手势触摸函数

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1)
    {
        UITouch*	touch = [[event touchesForView:self] anyObject];
		CGPoint touchpoint = [touch previousLocationInView:self];
        
        //矩形判断
		NSInteger rectIndex = [self getPointInRect: touchpoint];
		switch (rectIndex)
        {
			case 0:
				[self touchArea: kPTZ_DirectionBottom];
				[self touchArea: kPTZ_DirectionLeft];
				break;
			case 1:
				[self touchArea: kPTZ_DirectionLeft];
				break;
			case 2:
				[self touchArea: kPTZ_DirectionTop];
				[self touchArea: kPTZ_DirectionLeft];
				break;
			case 3:
				[self touchArea: kPTZ_DirectionBottom];
				break;
			case 5:
				[self touchArea: kPTZ_DirectionTop];
				break;
			case 6:
				[self touchArea: kPTZ_DirectionBottom];
				[self touchArea: kPTZ_DirectionRight];
				break;
			case 7:
				[self touchArea: kPTZ_DirectionRight];
				break;
			case 8:
				[self touchArea: kPTZ_DirectionRight];
				[self touchArea: kPTZ_DirectionTop];
				break;
			case 4:
			default:
				//[videoPlayerDelegate touchCentralArea];
				break;
		}
    }
}


- (UIImage*)snapshotImage{
    GLint backingWidth, backingHeight;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    
    // If your application only creates a single color renderbuffer which is already bound at this point,
    
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    
    // Note, replace viewRenderbuffer with the actual name of the renderbuffer object defined in your class.
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    // Get the size of the backing CAEAGLLayer
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    
    NSInteger dataLength = width * height * 4;
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    // Create a CGImage with the pixel data
    
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    
    // OpenGL ES measures data in PIXELS
    
    // Create a graphics context with the target size measured in POINTS
    
    NSInteger widthInPoints, heightInPoints;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        
        CGFloat scale = self.contentScaleFactor;
        
        widthInPoints = width / scale;
        
        heightInPoints = height / scale;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
        
    }
    
    else {
        
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        
        widthInPoints = width;
        
        heightInPoints = height;
        
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
        
    }
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    
    // Flip the CGImage by rendering it to the flipped bitmap context
    
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    
    
    // Retrieve the UIImage from the current context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    UIGraphicsEndImageContext();
    
    // Clean up
    
    free(data);
    
    CFRelease(ref);
    
    CFRelease(colorspace);
    
    CGImageRelease(iref);
    
    return image;
}

@end

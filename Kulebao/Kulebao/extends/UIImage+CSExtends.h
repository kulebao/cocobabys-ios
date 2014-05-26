//
//  UIImage+CSExtends.h
//
//
//  Created by xin.c.wang on 13-5-23.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CSExtends)
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end

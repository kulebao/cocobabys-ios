//
//  UIImage+Utility.h
//  XHImageViewer


#import <UIKit/UIKit.h>

@interface UIImage (Utility)
+ (UIImage *)fastImageWithData:(NSData *)data;
+ (UIImage *)fastImageWithContentsOfFile:(NSString *)path;
@end

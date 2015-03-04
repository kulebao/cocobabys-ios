//
//  XHFileAttribute.h
//  XHImageViewer

#import <Foundation/Foundation.h>

@interface XHFileAttribute : NSObject

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSDictionary *fileAttributes;
@property (nonatomic, readonly) NSDate *fileModificationDate;
- (id)initWithPath:(NSString *)filePath attributes:(NSDictionary *)attributes;

@end

//
//  CSKuleURLDownloader.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-29.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleURLDownloader : NSObject

+(instancetype)URLDownloader:(NSURL*)url;

- (void)start;

@end
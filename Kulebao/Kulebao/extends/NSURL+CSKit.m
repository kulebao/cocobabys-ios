//
//  NSURL+CSKit.m
//  Kulebao
//
//  Created by xin.c.wang on 14-4-1.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#import "NSURL+CSKit.h"

@implementation NSURL (CSKit)

- (NSURL*)URLByQiniuImageView:(NSString*)op {
    NSString* imgUrlString = [NSString stringWithFormat:@"%@?imageView2%@",
                              [self absoluteString], op];

    return [NSURL URLWithString:imgUrlString];
}

@end

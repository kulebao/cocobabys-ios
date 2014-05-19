//
//  CSKuleMediaInfo.m
//  youlebao
//
//  Created by xin.c.wang on 14-5-19.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleMediaInfo.h"

@implementation CSKuleMediaInfo
@synthesize url = _url;
@synthesize type = _type;

- (NSString*)description {
    NSDictionary* meta = @{@"url": _url,
                           @"type": _type};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

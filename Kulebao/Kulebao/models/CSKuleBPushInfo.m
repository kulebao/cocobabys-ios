//
//  CSKuleBPushInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-19.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleBPushInfo.h"

@implementation CSKuleBPushInfo
@synthesize appId = _appId;
@synthesize userId = _userId;
@synthesize channelId = _channelId;

- (NSString*)description {
    NSDictionary* meta = @{@"appId" : _appId,
                           @"userId": _userId,
                           @"channelId": _channelId};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end
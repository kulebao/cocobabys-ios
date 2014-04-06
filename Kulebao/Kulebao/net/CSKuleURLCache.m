//
//  CSKuleURLCache.m
//  Kulebao
//
//  Created by xin.c.wang on 14-4-2.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleURLCache.h"

@implementation CSKuleURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    //CSLog(@"%s", __FUNCTION__);
    NSCachedURLResponse* res = [super cachedResponseForRequest:request];
    return res;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    //CSLog(@"%s", __FUNCTION__);
    [super storeCachedResponse:cachedResponse forRequest:request];
}

@end

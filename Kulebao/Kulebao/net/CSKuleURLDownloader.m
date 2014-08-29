//
//  CSKuleURLDownloader.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-29.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleURLDownloader.h"
#import "TSFileCache.h"
#import "NSString+XHMD5.h"
#import "BDMultiDownloader.h"
#import "amrFileCodec.h"

@implementation CSKuleURLDownloader {
    NSURLConnection* _connection;
}

+(instancetype)URLDownloader:(NSURL*)url {
    CSKuleURLDownloader* obj = [[CSKuleURLDownloader alloc] initWithURL:url];
    return obj;
}

- (id)initWithURL:(NSURL*)url {
    if (self = [super init]) {
        _connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    TSFileCache* cache = [TSFileCache sharedInstance];
    if (cache && data) {
        NSData* waveData = DecodeAMRToWAVE(data);
        
        [cache storeData:waveData
                  forKey:connection.originalRequest.URL.absoluteString.MD5Hash];
    }
}

- (void)start {
    [_connection start];
}

@end

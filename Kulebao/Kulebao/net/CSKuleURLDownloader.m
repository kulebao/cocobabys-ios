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
#import "amrFileCodec.h"

enum {
    kDownloaderTypeAudio,
    kDownloaderTypeVideo
};

@implementation CSKuleURLDownloader {
    NSURLConnection* _connection;
    NSInteger _type;
}

+(instancetype)audioURLDownloader:(NSURL*)url {
    CSKuleURLDownloader* obj = [[CSKuleURLDownloader alloc] initWithURL:url
                                withType:kDownloaderTypeAudio];
    return obj;
}

+(instancetype)videoURLDownloader:(NSURL*)url {
    CSKuleURLDownloader* obj = [[CSKuleURLDownloader alloc] initWithURL:url
                                                               withType:kDownloaderTypeVideo];
    return obj;
}

- (id)initWithURL:(NSURL*)url withType:(NSInteger)type{
    if (self = [super init]) {
        _type = type;
        _connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    TSFileCache* cache = [TSFileCache sharedInstance];
    if (cache && data) {
        if (_type == kDownloaderTypeAudio) {
            NSData* waveData = DecodeAMRToWAVE(data);
            
            [cache storeData:waveData
                      forKey:connection.originalRequest.URL.absoluteString.MD5Hash];
        }
        else {
            [cache storeData:data
                      forKey:connection.originalRequest.URL.absoluteString.MD5HashEx];
        }
    }
}

- (void)start {
    [_connection start];
}

+(BOOL)cacheAudioData:(NSData*)data forURL:(NSURL*)url {
    BOOL ret = YES;
    
    TSFileCache* cache = [TSFileCache sharedInstance];
    [cache storeData:data
              forKey:url.absoluteString.MD5Hash];
    
    return ret;
}

+(BOOL)cacheVideoData:(NSData*)data forURL:(NSURL*)url {
    BOOL ret = YES;
    
    TSFileCache* cache = [TSFileCache sharedInstance];
    [cache storeData:data
              forKey:url.absoluteString.MD5HashEx];
    
    return ret;
}

@end

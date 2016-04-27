//
//  CSKuleBPushInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-19.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleBPushInfo : NSObject
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* channelId;

- (BOOL)isValid;

@end

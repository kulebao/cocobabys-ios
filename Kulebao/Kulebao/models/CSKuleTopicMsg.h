//
//  CSKuleTopicMsg.h
//  youlebao
//
//  Created by xin.c.wang on 14-5-19.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKuleSenderInfo.h"
#import "CSKuleMediaInfo.h"

@interface CSKuleTopicMsg : NSObject

/*
 {"topic":"1_1396844597394",
 "timestamp":112312313123,
 "id":1,
 "content":"老师你好，我们家王大侠怎么样。",
 "media":{"url":"http://suoqin-test.u.qiniudn.com/FgPmIcRG6BGocpV1B9QMCaaBQ9LK","type":"image"},
 "sender":{"id":"2_1003_1396844438388","type":"p"}
 }
 */

@property (nonatomic, strong) NSString* topic;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) long long msgId;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) CSKuleMediaInfo* media;
@property (nonatomic, strong) CSKuleSenderInfo* sender;

@end
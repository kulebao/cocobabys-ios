//
//  CSKuleTopicMsg.m
//  youlebao
//
//  Created by xin.c.wang on 14-5-19.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleTopicMsg.h"

@implementation CSKuleTopicMsg

@synthesize topic = _topic;
@synthesize timestamp = _timestamp;
@synthesize msgId = _msgId;
@synthesize content = _content;
@synthesize media = _media;
@synthesize sender = _sender;

- (NSString*)description {
    NSDictionary* meta = @{
                           @"topic": _topic,
                           @"timestamp": @(_timestamp),
                           @"msgId": @(_msgId),
                           @"content": _content,
                           @"media": _media,
                           @"sender": _sender};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

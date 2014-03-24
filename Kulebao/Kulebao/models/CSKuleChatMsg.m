//
//  CSKuleChatMsg.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatMsg.h"

@implementation CSKuleChatMsg
@synthesize phone = _phone;
@synthesize timestamp = _timestamp;
@synthesize msgId = _msgId;
@synthesize content = _content;
@synthesize image = _image;
@synthesize sender = _sender;

- (NSString*)description {
    NSDictionary* meta = @{@"phone": _phone,
                           @"timestamp": @(_timestamp),
                           @"msgId": @(_msgId),
                           @"content": _content,
                           @"image": _image,
                           @"sender": _sender};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

//
//  CSKuleSenderInfo.m
//  youlebao
//
//  Created by xin.c.wang on 14-5-19.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleSenderInfo.h"

@implementation CSKuleSenderInfo
@synthesize senderId = _senderId;
@synthesize type = _type;

- (NSString*)description {
    NSDictionary* meta = @{@"senderId": _senderId,
                           @"type": _type};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

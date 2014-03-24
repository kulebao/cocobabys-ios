//
//  CSKuleChatMsg.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleChatMsg : NSObject

@property (nonatomic, strong) NSString* phone;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) long long msgId;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* image;
@property (nonatomic, strong) NSString* sender;

@end

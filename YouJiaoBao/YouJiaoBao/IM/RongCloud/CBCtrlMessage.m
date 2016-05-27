//
//  CBCtrlMessage.m
//  youlebao
//
//  Created by WangXin on 5/11/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBCtrlMessage.h"

@implementation CBCtrlMessage

+ (NSString *)getObjectName {
    return CBCtrlMessageTypeIdentifier;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end

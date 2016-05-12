//
//  CBTextMessage.h
//  youlebao
//
//  Created by WangXin on 5/11/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define CBTextMessageTypeIdentifier @"CB:TxtMsg"

@interface CBTextMessage : RCTextMessage

+ (NSString *)getObjectName;

@end

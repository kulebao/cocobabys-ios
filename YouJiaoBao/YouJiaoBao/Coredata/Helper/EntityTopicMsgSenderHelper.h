//
//  EntityTopicMsgSenderHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-10-11.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityTopicMsgSender.h"

@interface EntityTopicMsgSenderHelper : NSObject

+ (EntityTopicMsgSender*)queryEntityWithUid:(NSString*)uid;
+ (NSArray*)updateEntities:(id)jsonObjectList;

@end

//
//  EntityTopicMsgHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-17.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityTopicMsg.h"

@interface EntityTopicMsgHelper : NSObject

+ (EntityTopicMsg*)queryEntityWithUid:(NSNumber*)uid;

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (void)markAsRead:(EntityTopicMsg*)entity;

@end

//
//  EntityParentInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityParentInfo.h"

@interface EntityParentInfoHelper : NSObject

+ (EntityParentInfo*)queryEntityWithParentId:(NSString*)parentId;

+ (NSArray*)updateEntities:(id)jsonObjectList;

@end

//
//  EntityAssessInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-3.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAssessInfo.h"

@interface EntityAssessInfoHelper : NSObject

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (EntityAssessInfo*)lastEntityOfChild:(NSString*)childId;

@end

//
//  EntityClassInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-21.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityClassInfo.h"

@interface EntityClassInfoHelper : NSObject

+ (EntityClassInfo*)queryEntityWithClassId:(NSInteger)classId;

+ (NSArray*)updateEntities:(id)jsonObjectList forEmployee:(NSString*)employeeId ofKindergarten:(NSInteger)kindergartenId;

+ (NSFetchedResultsController*)frClassesWithEmployee:(NSString*)employeeId ofKindergarten:(NSInteger)kindergartenId;

@end

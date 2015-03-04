//
//  EntityChildInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-4.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityChildInfo.h"

@interface EntityChildInfoHelper : NSObject

+ (EntityChildInfo*)queryEntityWithChildId:(NSString*)childId;

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (NSFetchedResultsController*)frChildrenWithClassId:(NSInteger)classId
                                      ofKindergarten:(NSInteger)kindergartenId;

+ (NSFetchedResultsController*)frChildrenWithKindergarten:(NSInteger)kindergartenId;

@end

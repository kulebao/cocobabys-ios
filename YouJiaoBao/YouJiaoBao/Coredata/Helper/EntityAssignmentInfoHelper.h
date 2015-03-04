//
//  EntityAssignmentInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-10.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityAssignmentInfo.h"

@interface EntityAssignmentInfoHelper : NSObject

+ (EntityAssignmentInfo*)queryEntityWithAssignmentId:(NSNumber*)uid;

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (void)markAsRead:(EntityAssignmentInfo*)entity;

+ (NSFetchedResultsController*)frAssignmentsWithClassList:(NSArray*)classIdList
                                           ofKindergarten:(NSInteger)kindergartenId;

@end

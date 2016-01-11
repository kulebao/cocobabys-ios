//
//  EntityNewsInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-9.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityNewsInfo.h"

@interface EntityNewsInfoHelper : NSObject

+ (EntityNewsInfo*)queryEntityWithNewsId:(NSNumber*)newsId;

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (void)markAsRead:(EntityNewsInfo*)entity;

+ (void)deleteEntity:(EntityNewsInfo*)entity;

+ (NSFetchedResultsController*)frNewsWithClassList:(NSArray*)classIdList
                                    ofKindergarten:(NSInteger)kindergartenId;

@end

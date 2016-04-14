//
//  EntityHistoryInfoHelper.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityHistoryInfo.h"
#import "EntityMediaInfo.h"

@interface EntityHistoryInfoHelper : NSObject

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (NSFetchedResultsController*)frCtrlForYear:(NSInteger)year month:(NSInteger)month topic:(NSString*)topic; // month 1 - 12

+ (EntityMediaInfo*)mediaWhereLatestImageOfYear:(NSInteger)year month:(NSInteger)month topic:(NSString*)topic;

+ (void)deleteEntity:(EntityHistoryInfo*)entity;

@end

//
//  EntityRelationshipInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRelationshipInfo.h"

@interface EntityRelationshipInfoHelper : NSObject

+ (EntityRelationshipInfo*)queryEntityWithRelationshipId:(NSInteger)uid;

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (NSFetchedResultsController*)frRelationshipOfKindergarten:(NSInteger)kindergartenId;

@end

//
//  EntityParentInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityParentInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityParentInfoHelper

+ (EntityParentInfo*)queryEntityWithParentId:(NSString*)parentId {
    EntityParentInfo* entity = nil;
    if (parentId) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityParentInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"parentId == %@", parentId]];
        fr.returnsDistinctResults = YES;
        fr.fetchLimit = 1;
        fr.resultType = NSManagedObjectResultType;
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:fr error:&error];
        entity = [results lastObject];
    }
    
    return entity;
}

+ (NSArray*)updateEntities:(id)jsonObjectList {
    NSMutableArray* returnObjectList = [NSMutableArray array];
    
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        NSString* parentId = [jsonObject objectForKey:@"parent_id"];
        if (parentId.length > 0) {
            EntityParentInfo* entity = [self queryEntityWithParentId:parentId];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityParentInfo" inManagedObjectContext:context];
                entity.parentId = parentId;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            if (updated) {
                entity.birthday = [jsonObject objectForKey:@"birthday"];
                entity.gender = [jsonObject objectForKey:@"gender"];
                entity.name = [jsonObject objectForKey:@"name"];
                entity.portrait = [jsonObject objectForKey:@"portrait"];
                entity.schoolId = [jsonObject objectForKey:@"school_id"];
                entity.status = [jsonObject objectForKey:@"status"];
                entity.timestamp = [jsonObject objectForKey:@"timestamp"];
                entity.company = [jsonObject objectForKey:@"company"];
                entity.memberStatus = [jsonObject objectForKey:@"member_status"];
                entity.phone = [jsonObject objectForKey:@"phone"];
            }
            entity.uid = [jsonObject objectForKey:@"id"];
            
            [returnObjectList addObject:entity];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

@end

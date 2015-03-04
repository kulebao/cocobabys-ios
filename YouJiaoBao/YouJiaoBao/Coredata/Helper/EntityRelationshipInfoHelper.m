//
//  EntityRelationshipInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityRelationshipInfoHelper.h"
#import "EntityParentInfoHelper.h"
#import "EntityChildInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityRelationshipInfoHelper

+ (EntityRelationshipInfo*)queryEntityWithRelationshipId:(NSInteger)uid {
    EntityRelationshipInfo* entity = nil;
    if (uid > 0) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityRelationshipInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"uid == %d", uid]];
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
        NSInteger uid = [[jsonObject objectForKey:@"id"] integerValue];
        if (uid > 0) {
            EntityRelationshipInfo* entity = [self queryEntityWithRelationshipId:uid];
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityRelationshipInfo" inManagedObjectContext:context];
                entity.uid = @(uid);
            }
            
            entity.card = [jsonObject objectForKey:@"card"];
            entity.relationship = [jsonObject objectForKey:@"relationship"];
            
            NSDictionary* childJsonObject = [jsonObject objectForKey:@"child"];
            if (childJsonObject) {
                entity.childInfo = [[EntityChildInfoHelper updateEntities:@[childJsonObject]] firstObject];
            }
            else {
                entity.childInfo = nil;
            }
            
            NSDictionary* parentJsonObject = [jsonObject objectForKey:@"parent"];
            if (parentJsonObject) {
                entity.parentInfo = [[EntityParentInfoHelper updateEntities:@[parentJsonObject]] firstObject];
            }
            else {
                entity.parentInfo = nil;
            }
            
            [returnObjectList addObject:entity];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

@end

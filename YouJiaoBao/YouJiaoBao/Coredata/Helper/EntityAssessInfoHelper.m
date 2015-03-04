//
//  EntityAssessInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-3.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityAssessInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityAssessInfoHelper

+ (EntityAssessInfo*)queryEntityWithUid:(NSNumber*)uid {
    EntityAssessInfo* entity = nil;
    if (uid.integerValue > 0) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityAssessInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"uid == %@", uid]];
        fr.returnsDistinctResults = YES;
        fr.fetchLimit = 1;
        fr.resultType = NSManagedObjectResultType;
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:fr error:&error];
        entity = [results lastObject];
    }
    
    return entity;
}

+ (EntityAssessInfo*)lastEntityOfChild:(NSString*)childId {
    EntityAssessInfo* entity = nil;
    if (childId) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityAssessInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"childId == %@", childId]];
        fr.returnsDistinctResults = YES;
        fr.fetchLimit = 1;
        fr.resultType = NSManagedObjectResultType;
        NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
        [fr setSortDescriptors:@[sortDesc]];
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:fr error:&error];
        entity = [results firstObject];
    }
    
    return entity;
    
}

+ (NSArray*)updateEntities:(id)jsonObjectList {
    NSMutableArray* returnObjectList = [NSMutableArray array];
    
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        NSNumber* uid = [jsonObject objectForKey:@"id"];
        if (uid.integerValue > 0) {
            EntityAssessInfo* entity = [self queryEntityWithUid:uid];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityAssessInfo" inManagedObjectContext:context];
                entity.uid = uid;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            if (updated) {
                entity.publisher = [jsonObject objectForKey:@"publisher"];
                entity.comments = [jsonObject objectForKey:@"comments"];
                entity.dining = [jsonObject objectForKey:@"dining"];
                entity.emotion = [jsonObject objectForKey:@"emotion"];
                entity.rest = [jsonObject objectForKey:@"rest"];
                entity.activity = [jsonObject objectForKey:@"activity"];
                entity.game = [jsonObject objectForKey:@"game"];
                entity.exercise = [jsonObject objectForKey:@"exercise"];
                entity.selfCare = [jsonObject objectForKey:@"self_care"];
                entity.manner = [jsonObject objectForKey:@"manner"];
                entity.timestamp = [jsonObject objectForKey:@"timestamp"];
                entity.childId = [jsonObject objectForKey:@"child_id"];
                entity.schoolId = [jsonObject objectForKey:@"school_id"];
            }
            
            [returnObjectList addObject:entity];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

@end

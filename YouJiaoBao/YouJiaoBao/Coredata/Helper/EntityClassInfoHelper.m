//
//  EntityClassInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-21.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityClassInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityClassInfoHelper

+ (NSArray*)updateEntities:(id)jsonObjectList forEmployee:(NSString*)employeeId ofKindergarten:(NSInteger)kindergartenId {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    NSFetchedResultsController* frCtrl = [EntityClassInfoHelper frClassesWithEmployee:employeeId ofKindergarten:kindergartenId];
    
    NSError* error = nil;
    [frCtrl performFetch:&error];
    
    NSMutableArray* fetchedObjects = [NSMutableArray arrayWithArray:frCtrl.fetchedObjects];
    NSMutableArray* updatedObjects = [NSMutableArray array];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        NSInteger classId = [[jsonObject objectForKey:@"class_id"] integerValue];
        
        @try {
            NSArray* tmpObjectList = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"classId == %d", classId]];
            EntityClassInfo* entity = [tmpObjectList lastObject];
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityClassInfo" inManagedObjectContext:context];
                entity.classId = @(classId);
                entity.employeeId = employeeId;
            }
            else {
                [fetchedObjects removeObject:entity];
            }
            
            entity.name = [jsonObject objectForKey:@"name"];
            entity.schoolId = [jsonObject objectForKey:@"school_id"];
            [updatedObjects addObject:entity];
        }
        @catch (NSException *exception) {
            CSLog(@"exception:%@", exception);
        }
        @finally {
            
        }
    }
    
    for (EntityClassInfo* willDeleteObject in fetchedObjects) {
        [context deleteObject:willDeleteObject];
    }
    
    //[NSFetchedResultsController deleteCacheWithName:frCtrl.cacheName];
    [context save:&error];
    
    return updatedObjects;
}

+ (EntityClassInfo*)queryEntityWithClassId:(NSInteger)classId {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    EntityClassInfo* entity = nil;
    
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityClassInfo"];
    [fr setPredicate:[NSPredicate predicateWithFormat:@"classId == %d", classId]];
    fr.returnsDistinctResults = YES;
    fr.fetchLimit = 1;
    fr.resultType = NSManagedObjectResultType;
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fr error:&error];
    entity = [results lastObject];
    
    return entity;
}

+ (NSFetchedResultsController*)frClassesWithEmployee:(NSString*)employeeId ofKindergarten:(NSInteger)kindergartenId {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityClassInfo"];
    fr.resultType = NSManagedObjectResultType;
    
    [fr setPredicate:[NSPredicate predicateWithFormat:@"employeeId == %@ AND schoolId == %d", employeeId, kindergartenId]];
    
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"classId" ascending:YES];
    [fr setSortDescriptors:@[sortDesc]];
    
    NSString* cacheName = [NSString stringWithFormat:@"ClassesWithEmployee%@ofKindergarten%ld", employeeId, (long)kindergartenId];
    cacheName = nil;
    NSFetchedResultsController* frCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                                                             managedObjectContext:context
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:cacheName];
    
    return frCtrl;
}

@end

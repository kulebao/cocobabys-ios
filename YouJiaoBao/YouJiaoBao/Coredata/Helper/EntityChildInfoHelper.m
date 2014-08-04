//
//  EntityChildInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-4.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityChildInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityChildInfoHelper

+ (EntityChildInfo*)queryEntityWithChildId:(NSString*)childId {
    EntityChildInfo* entity = nil;
    if (childId) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityChildInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"childId == %@", childId]];
        fr.returnsDistinctResults = YES;
        fr.fetchLimit = 1;
        fr.resultType = NSManagedObjectResultType;
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:fr error:&error];
        entity = [results lastObject];
    }
    
    return entity;
}

+ (void)updateEntities:(id)jsonObjectList {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        NSString* childId = [jsonObject objectForKey:@"child_id"];
        if (childId.length > 0) {
            EntityChildInfo* entity = [self queryEntityWithChildId:childId];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityChildInfo" inManagedObjectContext:context];
                entity.childId = childId;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            if (updated) {
                entity.address = [jsonObject objectForKey:@"address"];
                entity.birthday = [jsonObject objectForKey:@"birthday"];
                entity.classId = [jsonObject objectForKey:@"class_id"];
                entity.classname = [jsonObject objectForKey:@"class_name"];
                entity.gender = [jsonObject objectForKey:@"gender"];
                entity.name = [jsonObject objectForKey:@"name"];
                entity.nick = [jsonObject objectForKey:@"nick"];
                entity.portrait = [jsonObject objectForKey:@"portrait"];
                entity.schoolId = [jsonObject objectForKey:@"school_id"];
                entity.status = [jsonObject objectForKey:@"status"];
                entity.timestamp = [jsonObject objectForKey:@"timestamp"];
            }
        }
    }
    
    NSError* error = nil;
    [context save:&error];
}

+ (NSFetchedResultsController*)frChildrenWithClassId:(NSInteger)classId
                                      ofKindergarten:(NSInteger)kindergartenId {

    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityChildInfo"];
    fr.resultType = NSManagedObjectResultType;
    
    [fr setPredicate:[NSPredicate predicateWithFormat:@"classId == %d AND schoolId == %d", classId, kindergartenId]];
    
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"childId" ascending:YES];
    [fr setSortDescriptors:@[sortDesc]];
    
    NSFetchedResultsController* frCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:context sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"ChildrenWithClassId%dofKindergarten%d", classId, kindergartenId]];
    
    return frCtrl;
}

@end

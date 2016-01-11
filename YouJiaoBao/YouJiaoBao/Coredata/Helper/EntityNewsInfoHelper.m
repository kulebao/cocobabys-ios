//
//  EntityNewsInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-9.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityNewsInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityNewsInfoHelper

+ (EntityNewsInfo*)queryEntityWithNewsId:(NSNumber*)newsId {
    EntityNewsInfo* entity = nil;
    if (newsId) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityNewsInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"newsId == %@", newsId]];
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
        NSNumber* newsId = [jsonObject objectForKey:@"news_id"];
        if (newsId.integerValue > 0) {
            EntityNewsInfo* entity = [self queryEntityWithNewsId:newsId];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityNewsInfo" inManagedObjectContext:context];
                entity.newsId = newsId;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            if (updated) {
                entity.classId = [jsonObject objectForKey:@"class_id"];
                entity.content = [jsonObject objectForKey:@"content"];
                entity.image = [jsonObject objectForKey:@"image"];
                entity.published = [jsonObject objectForKey:@"published"];
                entity.publisherId = [jsonObject objectForKey:@"publisher_id"];
                entity.title = [jsonObject objectForKey:@"title"];
                entity.schoolId = [jsonObject objectForKey:@"school_id"];
                entity.noticeType = [jsonObject objectForKey:@"notice_type"];
                entity.timestamp = [jsonObject objectForKey:@"timestamp"];
                entity.read = @(0);
                entity.feedbackRequired = [jsonObject objectForKey:@"feedback_required"];
                entity.tags = [[jsonObject objectForKey:@"tags"] componentsJoinedByString:@","];
                [returnObjectList addObject:entity];
            }
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

+ (void)markAsRead:(EntityNewsInfo*)entity {
    if (entity.read.integerValue <= 0) {
        entity.read = @(1);
        
         NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSError* error = nil;
        [context save:&error];
    }
}

+ (NSFetchedResultsController*)frNewsWithClassList:(NSArray*)classIdList
                                    ofKindergarten:(NSInteger)kindergartenId {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityNewsInfo"];
    fr.resultType = NSManagedObjectResultType;
    
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"schoolId == %d", kindergartenId];
    
    if (classIdList.count > 0) {
        NSMutableArray* orPres = [NSMutableArray array];
        for (NSString* classId in classIdList) {
            [orPres addObject:[NSPredicate predicateWithFormat:@"classId == %@", classId]];
        }
        
        [orPres addObject:[NSPredicate predicateWithFormat:@"classId == %d", 0]];
        
        NSPredicate* compPre = [NSCompoundPredicate orPredicateWithSubpredicates:orPres];
        
        pre = [NSCompoundPredicate andPredicateWithSubpredicates:@[pre, compPre]];
    }
    
    [fr setPredicate:pre];
    
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fr setSortDescriptors:@[sortDesc]];
    
    NSFetchedResultsController* frCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                                                             managedObjectContext:context
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:nil];
    
    return frCtrl;
}

+ (void)deleteEntity:(EntityNewsInfo*)entity {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    [context deleteObject:entity];
    NSError* error = nil;
    [context save:&error];
}

@end

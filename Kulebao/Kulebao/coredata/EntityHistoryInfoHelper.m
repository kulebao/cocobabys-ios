//
//  EntityHistoryInfoHelper.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "EntityHistoryInfoHelper.h"
#import "CSCoreDataHelper.h"
#import "EntitySenderInfoHelper.h"
#import "EntityMediaInfoHelper.h"

@implementation EntityHistoryInfoHelper
/*
 {
 content = "\U6d4b\U8bd5\U770b\U7f51\U9875\U663e\U793a\U95ee\U9898";
 id = 796;
 medium =     (
 {
 type = image;
 url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_180338.jpg";
 },
 {
 type = image;
 url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_145407.jpg";
 }
 );
 sender =     {
 id = "3_2088_1403762507321";
 type = t;
 };
 timestamp = 1406449306043;
 topic = "2_2088_900";
 },
 */

+ (EntityHistoryInfo*)queryEntityWithUid:(NSNumber*)uid {
    EntityHistoryInfo* entity = nil;
    if (uid) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityHistoryInfo"];
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

+ (NSArray*)updateEntities:(id)jsonObjectList {
    NSMutableArray* returnObjectList = [NSMutableArray array];
    
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        NSNumber* uid = [jsonObject objectForKey:@"id"];
        if (uid.integerValue > 0) {
            EntityHistoryInfo* entity = [self queryEntityWithUid:uid];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityHistoryInfo"
                                                       inManagedObjectContext:context];
                entity.uid = uid;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject valueForKeyNotNull:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            if (YES || updated) {
                entity.content = [jsonObject valueForKeyNotNull:@"content"];
                entity.topic = [jsonObject valueForKeyNotNull:@"topic"];
                entity.timestamp = [jsonObject valueForKeyNotNull:@"timestamp"];
                
                if (entity.sender) {
                    [context deleteObject:entity.sender];
                }
                
                NSArray* senderlist =[EntitySenderInfoHelper updateEntities:@[[jsonObject valueForKeyNotNull:@"sender"]]];
                
                entity.sender = senderlist.firstObject;
                
                if (entity.medium.count > 0) {
                    for (NSManagedObject* obj in entity.medium.allObjects) {
                        [context deleteObject:obj];
                    }
                }
                
                NSArray* mediaInfoList = [EntityMediaInfoHelper updateEntities:[jsonObject valueForKeyNotNull:@"medium"]];
                entity.medium = [NSSet setWithArray:mediaInfoList];
            }
            
            [returnObjectList addObject:entity];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

+ (NSFetchedResultsController*)frCtrlForYear:(NSInteger)year month:(NSInteger)month {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityHistoryInfo"];
    fr.resultType = NSManagedObjectResultType;
    
    if (month > 12) {
        month = 12;
    }
    else if (month < 0) {
        month = 0;
    }
    
    NSString* fromDateString = [NSString stringWithFormat:@"%d-%d-01 00:00:00", year, month];
    NSString* toDateString = [NSString stringWithFormat:@"%d-%d-01 00:00:00", year, month+1];
    
    if (month >= 12) {
        fromDateString = [NSString stringWithFormat:@"%d-12-01 00:00:00", year];
        toDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", year+1];
    }
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate* fromDate = [fmt dateFromString:fromDateString];
    NSDate* toDate = [fmt dateFromString:toDateString];
    
    double fromTimestamp = [fromDate timeIntervalSince1970] * 1000;
    double toTimestamp = [toDate timeIntervalSince1970] * 1000;
    
    
    [fr setPredicate:[NSPredicate predicateWithFormat:@"timestamp >= %lf AND timestamp < %lf", fromTimestamp, toTimestamp]];
    
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    [fr setSortDescriptors:@[sortDesc]];
    
    NSFetchedResultsController* frCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return frCtrl;
}

+ (EntityMediaInfo*)mediaWhereLatestImageOfYear:(NSInteger)year month:(NSInteger)month {
    NSFetchedResultsController* frCtrl = [EntityHistoryInfoHelper frCtrlForYear:year month:month];
    
    NSError* error = nil;
    [frCtrl performFetch:&error];
    
    EntityMediaInfo* returnEntity = nil;
    
    for (EntityHistoryInfo* entity in frCtrl.fetchedObjects) {
        if (entity.medium.count > 0) {
            for(EntityMediaInfo* media in entity.medium) {
                if ([media.type isEqualToString:@"image"]) {
                    returnEntity = media;
                    break;
                }
            }
            
            if (returnEntity != nil) {
                break;
            }
        }
    }
    
    return returnEntity;
}

@end

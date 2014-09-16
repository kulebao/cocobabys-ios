//
//  EntityDailylogHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-16.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityDailylogHelper.h"
#import "CSCoreDataHelper.h"
#import "EntityChildInfoHelper.h"
#import "NSDate+CSKit.h"

@implementation EntityDailylogHelper

+ (NSArray*)updateEntities:(id)jsonObjectList {
    NSMutableArray* returnObjectList = [NSMutableArray array];
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        NSString* childId = [jsonObject objectForKey:@"child_id"];
        EntityChildInfo* childInfo = [EntityChildInfoHelper queryEntityWithChildId:childId];
        if (childInfo) {
            if (childInfo.dailylog) {
                [EntityDailylogHelper updateEntity:childInfo.dailylog withJsonObject:jsonObject];
            }
            else {
                childInfo.dailylog = [NSEntityDescription insertNewObjectForEntityForName:@"EntityDailylog"
                                                                       inManagedObjectContext:context];
                [EntityDailylogHelper updateEntity:childInfo.dailylog withJsonObject:jsonObject];
            }
            
            [returnObjectList addObject:childInfo.dailylog];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

/*
 {
 "child_id" = "2_2088_896";
 "notice_type" = 1;
 "parent_name" = "\U738b\U946b";
 "record_url" = "http://suoqin-test.u.qiniudn.com/FoUJaV4r5L0bM0414mGWEIuCLEdL";
 timestamp = 1410841487532;
 }
 */
+ (EntityDailylog*)updateEntity:(EntityDailylog*)entity withJsonObject:(id)jsonObject {
    if (entity) {
        entity.childId = [jsonObject objectForKey:@"child_id"];
        entity.noticeType = [jsonObject objectForKey:@"notice_type"];
        entity.parentName = [jsonObject objectForKey:@"parent_name"];
        entity.recordUrl = [jsonObject objectForKey:@"record_url"];
        entity.timestamp = [jsonObject objectForKey:@"timestamp"];
    }
    
    return entity;
}


+ (BOOL)isDailylogOfToday:(EntityDailylog*)entity {
    BOOL ok = NO;
    if (entity) {
        NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:entity.timestamp.longLongValue / 1000];
        if ([timestamp.isoDateString isEqualToString:[[NSDate date] isoDateString]]) {
            ok = YES;
        }
    }

    return ok;
}

@end

//
//  EntityTopicMsgHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-17.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityTopicMsgHelper.h"
#import "CSCoreDataHelper.h"
#import "EntityChildInfoHelper.h"

@implementation EntityTopicMsgHelper

+ (EntityTopicMsg*)queryEntityWithUid:(NSNumber*)uid {
    EntityTopicMsg* entity = nil;
    if (uid) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityTopicMsg"];
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
            EntityTopicMsg* entity = [self queryEntityWithUid:uid];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityTopicMsg" inManagedObjectContext:context];
                entity.uid = uid;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            /*
             content = "\U53ef\U4ee5\U554a\Uff0c\U6ca1\U95ee\U9898\U3002";
             id = 671;
             media =     {
                type = "";
                url = "";
             };
             medium =     (
             );
             sender =     {
                id = "3_2088_1403762507321";
                type = t;
             };
             timestamp = 1406086399006;
             topic = "1_1403768645951";
             */
            if (updated) {
                entity.topic = [jsonObject objectForKey:@"topic"];
                entity.content = [jsonObject objectForKey:@"content"];
                entity.timestamp = [jsonObject objectForKey:@"timestamp"];
                entity.read = @(0);
                
                entity.medium = nil;
                
                NSDictionary* senderInfo = [jsonObject objectForKey:@"sender"];
                if (senderInfo) {
                    entity.senderId = [senderInfo objectForKey:@"id"];
                    entity.senderType = [senderInfo objectForKey:@"type"];
                }
                else {
                    entity.senderId = nil;
                    entity.senderType = nil;
                }
                
                NSDictionary* mediaInfo = [jsonObject objectForKey:@"media"];
                if (mediaInfo) {
                    entity.mediaUrl = [mediaInfo objectForKey:@"url"];
                    entity.mediaType = [mediaInfo objectForKey:@"type"];
                }
                else {
                    entity.mediaUrl = nil;
                    entity.mediaType = nil;
                }
            }
            
            EntityChildInfo* childInfo = [EntityChildInfoHelper queryEntityWithChildId:entity.topic];
            if (childInfo) {
                if (childInfo.lastTopicMsg) {
                    if (entity.timestamp.longLongValue >= childInfo.lastTopicMsg.timestamp.longLongValue) {
                        childInfo.lastTopicMsg = entity;
                    }
                }
                else {
                    childInfo.lastTopicMsg = entity;
                }
            }
            
            [returnObjectList addObject:entity];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}


+ (void)markAsRead:(EntityTopicMsg*)entity {
    
}

@end

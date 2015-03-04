//
//  EntityTopicMsgSenderHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-10-11.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityTopicMsgSenderHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityTopicMsgSenderHelper

+ (EntityTopicMsgSender*)queryEntityWithUid:(NSString*)uid {
    EntityTopicMsgSender* entity = nil;
    if (uid) {
        NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityTopicMsgSender"];
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
        NSString* senderId = nil;
        NSString* senderType = nil;
        NSString* parentId = [jsonObject objectForKey:@"parent_id"];
        if (parentId.length > 0) {
            senderId = parentId;
            senderType = @"p";
        }
        else {
            senderId = [jsonObject objectForKey:@"id"];
            senderType = @"t";
        }
        
        if (senderId.length > 0) {
            EntityTopicMsgSender* entity = [self queryEntityWithUid:senderId];
            BOOL updated = NO;
            if (entity == nil) {
                entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityTopicMsgSender" inManagedObjectContext:context];
                entity.uid = senderId;
                updated = YES;
            }
            else {
                NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
                if (![timestamp isEqualToNumber:entity.timestamp]) {
                    updated = YES;
                }
            }
            
            if (updated) {
                entity.name = [jsonObject objectForKey:@"name"];
                entity.phone = [jsonObject objectForKey:@"phone"];
                entity.gender = [jsonObject objectForKey:@"gender"];
                entity.portrait = [jsonObject objectForKey:@"portrait"];
                entity.schoolId = [jsonObject objectForKey:@"school_id"];
                entity.timestamp = [jsonObject objectForKey:@"timestamp"];
            }
            
            [returnObjectList addObject:entity];
        }
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

@end

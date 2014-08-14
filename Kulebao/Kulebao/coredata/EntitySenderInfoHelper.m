//
//  EntitySenderInfoHelper.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "EntitySenderInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntitySenderInfoHelper

+ (NSArray*)updateEntities:(id)jsonObjectList {
    NSMutableArray* returnObjectList = [NSMutableArray array];
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        EntitySenderInfo* entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntitySenderInfo"
                                                                 inManagedObjectContext:context];
        entity.senderId = [jsonObject valueForKeyNotNull:@"id"];
        entity.type = [jsonObject valueForKeyNotNull:@"type"];
        
        [returnObjectList addObject:entity];
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

@end

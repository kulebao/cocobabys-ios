//
//  EntityMediaInfoHelper.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "EntityMediaInfoHelper.h"
#import "CBCoreDataHelper.h"

@implementation EntityMediaInfoHelper

+ (NSArray*)updateEntities:(id)jsonObjectList {
    NSMutableArray* returnObjectList = [NSMutableArray array];
    NSManagedObjectContext* context = [[CBCoreDataHelper sharedInstance] managedObjectContext];
    
    for (NSDictionary* jsonObject in jsonObjectList) {
        EntityMediaInfo* entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityMediaInfo"
                                                                 inManagedObjectContext:context];
        entity.url = [jsonObject valueForKeyNotNull:@"url"];
        entity.type = [jsonObject valueForKeyNotNull:@"type"];
        
        [returnObjectList addObject:entity];
    }
    
    NSError* error = nil;
    [context save:&error];
    
    return returnObjectList;
}

@end

//
//  EntityLoginInfoHelper.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "EntityLoginInfoHelper.h"
#import "CSCoreDataHelper.h"

@implementation EntityLoginInfoHelper

+ (EntityLoginInfo*)updateEntity:(id)jsonObject {
    EntityLoginInfo* entity = nil;
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSString* uid = [jsonObject objectForKey:@"id"];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityLoginInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"uid == %@", uid]];
        fr.returnsDistinctResults = YES;
        fr.fetchLimit = 20;
        fr.resultType = NSManagedObjectResultType;
        
        NSError* error = nil;
        NSArray* results = [context executeFetchRequest:fr error:&error];
        entity = [results lastObject];
        
        BOOL needUpdate = NO;
        NSNumber* timestamp = [jsonObject objectForKey:@"timestamp"];
        if (entity == nil) {
            entity = [NSEntityDescription insertNewObjectForEntityForName:@"EntityLoginInfo" inManagedObjectContext:context];
            entity.uid = uid;
            needUpdate = YES;
        }
        else {
            needUpdate = ![timestamp isEqualToNumber:entity.timestamp];
        }
        
        if (needUpdate) {
            entity.gender = [jsonObject objectForKey:@"gender"];
            entity.name = [jsonObject objectForKey:@"name"];
            entity.phone = [jsonObject objectForKey:@"phone"];
            entity.portrait = [jsonObject objectForKey:@"portrait"];
            entity.schoolId = [jsonObject objectForKey:@"school_id"];
            entity.status = [jsonObject objectForKey:@"status"];
            entity.timestamp = [jsonObject objectForKey:@"timestamp"];
            entity.workduty = [jsonObject objectForKey:@"workduty"];
            entity.workgroup = [jsonObject objectForKey:@"workgroup"];
            entity.birthday = [jsonObject objectForKey:@"birthday"];
            entity.loginName = [jsonObject objectForKey:@"login_name"];
        }
        
        entity.loginDate = [NSDate date];
        
        [context save:&error];
    }
    
    return entity;
}

+ (NSFetchedResultsController*)frRecentLoginUser {
    NSManagedObjectContext* context = [[CSCoreDataHelper sharedInstance] managedObjectContext];
    
    NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityLoginInfo"];
    fr.fetchLimit = 1;
    fr.resultType = NSManagedObjectResultType;
    
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"loginDate" ascending:NO];
    [fr setSortDescriptors:@[sortDesc]];
    
    NSFetchedResultsController* frCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:context sectionNameKeyPath:nil cacheName:@"RecentLoginUser"];
    
    return frCtrl;
}

@end

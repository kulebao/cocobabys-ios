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
        NSString* o_id = [jsonObject objectForKey:@"id"];
        
        NSFetchRequest* fr = [[NSFetchRequest alloc] initWithEntityName:@"EntityLoginInfo"];
        [fr setPredicate:[NSPredicate predicateWithFormat:@"o_id == %@", o_id]];
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
            entity.o_id = o_id;
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
            entity.uid = [jsonObject objectForKey:@"uid"];
        }
        
        NSDictionary* imDict = [jsonObject valueForKeyNotNull:@"im_token"];
        if (imDict) {
            entity.im_token = [imDict valueForKeyNotNull:@"token"];;
            entity.im_user_id = [imDict valueForKeyNotNull:@"user_id"];
            entity.im_source = [imDict valueForKeyNotNull:@"source"];
        }
        else {
            entity.im_token = nil;
            entity.im_user_id = nil;
            entity.im_source = nil;
        }
        
        entity.loginDate = [NSDate date];
        entity.o_id = o_id;
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

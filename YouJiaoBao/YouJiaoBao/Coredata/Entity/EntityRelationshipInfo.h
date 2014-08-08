//
//  EntityRelationshipInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityChildInfo, EntityParentInfo;

@interface EntityRelationshipInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * card;
@property (nonatomic, retain) NSString * relationship;
@property (nonatomic, retain) EntityChildInfo *childInfo;
@property (nonatomic, retain) EntityParentInfo *parentInfo;

@end

//
//  EntityHistoryInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityMediaInfo;

@interface EntityHistoryInfo : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSSet *medium;
@property (nonatomic, retain) NSManagedObject *sender;
@end

@interface EntityHistoryInfo (CoreDataGeneratedAccessors)

- (void)addMediumObject:(EntityMediaInfo *)value;
- (void)removeMediumObject:(EntityMediaInfo *)value;
- (void)addMedium:(NSSet *)values;
- (void)removeMedium:(NSSet *)values;

@end

//
//  EntityHistoryInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityMediaInfo, EntitySenderInfo;

@interface EntityHistoryInfo : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSOrderedSet *medium;
@property (nonatomic, retain) EntitySenderInfo *sender;
@end

@interface EntityHistoryInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(EntityMediaInfo *)value inMediumAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMediumAtIndex:(NSUInteger)idx;
- (void)insertMedium:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMediumAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMediumAtIndex:(NSUInteger)idx withObject:(EntityMediaInfo *)value;
- (void)replaceMediumAtIndexes:(NSIndexSet *)indexes withMedium:(NSArray *)values;
- (void)addMediumObject:(EntityMediaInfo *)value;
- (void)removeMediumObject:(EntityMediaInfo *)value;
- (void)addMedium:(NSOrderedSet *)values;
- (void)removeMedium:(NSOrderedSet *)values;
@end

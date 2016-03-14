//
//  EntityHistoryInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 3/7/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityHistoryInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityHistoryInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *topic;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSOrderedSet<EntityMediaInfo *> *medium;
@property (nullable, nonatomic, retain) EntitySenderInfo *sender;

@end

@interface EntityHistoryInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(EntityMediaInfo *)value inMediumAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMediumAtIndex:(NSUInteger)idx;
- (void)insertMedium:(NSArray<EntityMediaInfo *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMediumAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMediumAtIndex:(NSUInteger)idx withObject:(EntityMediaInfo *)value;
- (void)replaceMediumAtIndexes:(NSIndexSet *)indexes withMedium:(NSArray<EntityMediaInfo *> *)values;
- (void)addMediumObject:(EntityMediaInfo *)value;
- (void)removeMediumObject:(EntityMediaInfo *)value;
- (void)addMedium:(NSOrderedSet<EntityMediaInfo *> *)values;
- (void)removeMedium:(NSOrderedSet<EntityMediaInfo *> *)values;

@end

NS_ASSUME_NONNULL_END

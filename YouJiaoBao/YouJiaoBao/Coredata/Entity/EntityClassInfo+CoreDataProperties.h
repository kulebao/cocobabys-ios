//
//  EntityClassInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/26/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityClassInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityClassInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *classId;
@property (nullable, nonatomic, retain) NSString *employeeId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSOrderedSet<EntityChildInfo *> *childrenList;

@end

@interface EntityClassInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(EntityChildInfo *)value inChildrenListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenListAtIndex:(NSUInteger)idx;
- (void)insertChildrenList:(NSArray<EntityChildInfo *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildrenListAtIndex:(NSUInteger)idx withObject:(EntityChildInfo *)value;
- (void)replaceChildrenListAtIndexes:(NSIndexSet *)indexes withChildrenList:(NSArray<EntityChildInfo *> *)values;
- (void)addChildrenListObject:(EntityChildInfo *)value;
- (void)removeChildrenListObject:(EntityChildInfo *)value;
- (void)addChildrenList:(NSOrderedSet<EntityChildInfo *> *)values;
- (void)removeChildrenList:(NSOrderedSet<EntityChildInfo *> *)values;

@end

NS_ASSUME_NONNULL_END

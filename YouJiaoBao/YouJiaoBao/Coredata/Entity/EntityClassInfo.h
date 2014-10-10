//
//  EntityClassInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-17.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityChildInfo;

@interface EntityClassInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * classId;
@property (nonatomic, retain) NSString * employeeId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSOrderedSet *childrenList;
@end

@interface EntityClassInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(EntityChildInfo *)value inChildrenListAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenListAtIndex:(NSUInteger)idx;
- (void)insertChildrenList:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenListAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildrenListAtIndex:(NSUInteger)idx withObject:(EntityChildInfo *)value;
- (void)replaceChildrenListAtIndexes:(NSIndexSet *)indexes withChildrenList:(NSArray *)values;
- (void)addChildrenListObject:(EntityChildInfo *)value;
- (void)removeChildrenListObject:(EntityChildInfo *)value;
- (void)addChildrenList:(NSOrderedSet *)values;
- (void)removeChildrenList:(NSOrderedSet *)values;
@end

//
//  EntityDailylog+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityDailylog.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityDailylog (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *childId;
@property (nullable, nonatomic, retain) NSNumber *noticeType;
@property (nullable, nonatomic, retain) NSString *parentName;
@property (nullable, nonatomic, retain) NSString *recordUrl;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) EntityChildInfo *childInfo;

@end

NS_ASSUME_NONNULL_END

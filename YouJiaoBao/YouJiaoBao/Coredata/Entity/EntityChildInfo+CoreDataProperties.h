//
//  EntityChildInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityChildInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityChildInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *birthday;
@property (nullable, nonatomic, retain) NSString *childId;
@property (nullable, nonatomic, retain) NSNumber *classId;
@property (nullable, nonatomic, retain) NSString *classname;
@property (nullable, nonatomic, retain) NSNumber *gender;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *nick;
@property (nullable, nonatomic, retain) NSString *portrait;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) EntityClassInfo *classInfo;
@property (nullable, nonatomic, retain) EntityDailylog *dailylog;
@property (nullable, nonatomic, retain) EntityTopicMsg *lastTopicMsg;

@end

NS_ASSUME_NONNULL_END

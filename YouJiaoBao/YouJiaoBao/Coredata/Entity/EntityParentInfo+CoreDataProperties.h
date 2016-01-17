//
//  EntityParentInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityParentInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityParentInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *birthday;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSNumber *gender;
@property (nullable, nonatomic, retain) NSNumber *memberStatus;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *parentId;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *portrait;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *timestamp;

@end

NS_ASSUME_NONNULL_END

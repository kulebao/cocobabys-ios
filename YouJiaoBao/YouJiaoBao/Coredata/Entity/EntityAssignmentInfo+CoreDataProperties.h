//
//  EntityAssignmentInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/26/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityAssignmentInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityAssignmentInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *classId;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *iconUrl;
@property (nullable, nonatomic, retain) NSString *publisher;
@property (nullable, nonatomic, retain) NSNumber *read;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *uid;

@end

NS_ASSUME_NONNULL_END

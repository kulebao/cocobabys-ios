//
//  EntityAssessInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/26/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityAssessInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityAssessInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *activity;
@property (nullable, nonatomic, retain) NSString *childId;
@property (nullable, nonatomic, retain) NSString *comments;
@property (nullable, nonatomic, retain) NSNumber *dining;
@property (nullable, nonatomic, retain) NSNumber *emotion;
@property (nullable, nonatomic, retain) NSNumber *exercise;
@property (nullable, nonatomic, retain) NSNumber *game;
@property (nullable, nonatomic, retain) NSNumber *manner;
@property (nullable, nonatomic, retain) NSString *publisher;
@property (nullable, nonatomic, retain) NSNumber *rest;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSNumber *selfCare;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSNumber *uid;

@end

NS_ASSUME_NONNULL_END

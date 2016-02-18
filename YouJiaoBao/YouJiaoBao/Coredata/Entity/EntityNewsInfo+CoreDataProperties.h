//
//  EntityNewsInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/26/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityNewsInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityNewsInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *classId;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSNumber *feedbackRequired;
@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSNumber *newsId;
@property (nullable, nonatomic, retain) NSNumber *noticeType;
@property (nullable, nonatomic, retain) NSNumber *published;
@property (nullable, nonatomic, retain) NSString *publisherId;
@property (nullable, nonatomic, retain) NSNumber *read;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSString *tags;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END

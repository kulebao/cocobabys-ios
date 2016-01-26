//
//  EntityLoginInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/26/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityLoginInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityLoginInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *birthday;
@property (nullable, nonatomic, retain) NSNumber *gender;
@property (nullable, nonatomic, retain) NSString *im_source;
@property (nullable, nonatomic, retain) NSString *im_token;
@property (nullable, nonatomic, retain) NSString *im_user_id;
@property (nullable, nonatomic, retain) NSDate *loginDate;
@property (nullable, nonatomic, retain) NSString *loginName;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *portrait;
@property (nullable, nonatomic, retain) NSNumber *schoolId;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *workduty;
@property (nullable, nonatomic, retain) NSString *workgroup;

@end

NS_ASSUME_NONNULL_END

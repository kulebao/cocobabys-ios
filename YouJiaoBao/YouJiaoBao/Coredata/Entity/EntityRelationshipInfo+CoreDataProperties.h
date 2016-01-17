//
//  EntityRelationshipInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityRelationshipInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityRelationshipInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *card;
@property (nullable, nonatomic, retain) NSString *relationship;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) EntityChildInfo *childInfo;
@property (nullable, nonatomic, retain) EntityParentInfo *parentInfo;

@end

NS_ASSUME_NONNULL_END

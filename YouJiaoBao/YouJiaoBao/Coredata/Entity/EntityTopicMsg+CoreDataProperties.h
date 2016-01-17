//
//  EntityTopicMsg+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityTopicMsg.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityTopicMsg (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *mediaType;
@property (nullable, nonatomic, retain) NSString *mediaUrl;
@property (nullable, nonatomic, retain) NSString *medium;
@property (nullable, nonatomic, retain) NSNumber *read;
@property (nullable, nonatomic, retain) NSString *senderId;
@property (nullable, nonatomic, retain) NSString *senderType;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *topic;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) EntityChildInfo *childInfo;

@end

NS_ASSUME_NONNULL_END

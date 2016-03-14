//
//  EntitySenderInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 3/7/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntitySenderInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntitySenderInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *senderId;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) EntityHistoryInfo *historyInfo;

@end

NS_ASSUME_NONNULL_END

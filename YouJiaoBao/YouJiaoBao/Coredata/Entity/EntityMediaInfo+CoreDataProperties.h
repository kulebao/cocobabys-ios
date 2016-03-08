//
//  EntityMediaInfo+CoreDataProperties.h
//  YouJiaoBao
//
//  Created by WangXin on 3/7/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EntityMediaInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntityMediaInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) EntityHistoryInfo *historyInfo;

@end

NS_ASSUME_NONNULL_END

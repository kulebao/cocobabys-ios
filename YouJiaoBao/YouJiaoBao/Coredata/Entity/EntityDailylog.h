//
//  EntityDailylog.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-17.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityChildInfo;

@interface EntityDailylog : NSManagedObject

@property (nonatomic, retain) NSString * childId;
@property (nonatomic, retain) NSNumber * noticeType;
@property (nonatomic, retain) NSString * parentName;
@property (nonatomic, retain) NSString * recordUrl;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) EntityChildInfo *childInfo;

@end

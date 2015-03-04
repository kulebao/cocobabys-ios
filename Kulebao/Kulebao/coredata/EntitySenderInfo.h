//
//  EntitySenderInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityHistoryInfo;

@interface EntitySenderInfo : NSManagedObject

@property (nonatomic, retain) NSString * senderId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) EntityHistoryInfo *historyInfo;

@end

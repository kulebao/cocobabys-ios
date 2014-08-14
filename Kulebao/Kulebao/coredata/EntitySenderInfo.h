//
//  EntitySenderInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntitySenderInfo : NSManagedObject

@property (nonatomic, retain) NSString * senderId;
@property (nonatomic, retain) NSString * type;

@end

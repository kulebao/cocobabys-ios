//
//  EntityMediaInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityMediaInfo : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * type;

@end

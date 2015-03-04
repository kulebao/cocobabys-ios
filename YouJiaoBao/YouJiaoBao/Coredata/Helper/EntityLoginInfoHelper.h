//
//  EntityLoginInfoHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityLoginInfo.h"

@interface EntityLoginInfoHelper : NSObject

+ (EntityLoginInfo*)updateEntity:(id)jsonObject;

+ (NSFetchedResultsController*)frRecentLoginUser;

@end

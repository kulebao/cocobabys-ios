//
//  EntityDailylogHelper.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-16.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityDailylog.h"

// 通知类型
enum KuleNoticeType {
    kKuleNoticeTypeCheckOut = 0,
    kKuleNoticeTypeCheckIn = 1,
    //早上上车，早上下车，下午上车，下午下车
    kKuleNoticeTypeCheckInCarMorning = 10,
    kKuleNoticeTypeCheckOutCarMorning = 11,
    kKuleNoticeTypeCheckInCarAfternoon = 12,
    kKuleNoticeTypeCheckOutCarAfternoon = 13,
};

@interface EntityDailylogHelper : NSObject

+ (NSArray*)updateEntities:(id)jsonObjectList;

+ (BOOL)isDailylogOfToday:(EntityDailylog*)entity;

@end

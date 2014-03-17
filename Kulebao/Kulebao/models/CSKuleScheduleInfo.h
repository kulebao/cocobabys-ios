//
//  CSKuleScheduleInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKuleWeekScheduleInfo.h"

@interface CSKuleScheduleInfo : NSObject

@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger classId;
@property (nonatomic, assign) NSInteger scheduleId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) CSKuleWeekScheduleInfo* week;

@end

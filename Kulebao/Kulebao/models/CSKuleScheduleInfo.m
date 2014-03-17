//
//  CSKuleScheduleInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleScheduleInfo.h"

@implementation CSKuleScheduleInfo

@synthesize errorCode = _errorCode;
@synthesize schoolId = _schoolId;
@synthesize classId = _classId;
@synthesize scheduleId = _scheduleId;
@synthesize timestamp = _timestamp;
@synthesize week = _week;

- (NSString*)description {
    NSDictionary* meta = @{@"errorCode": @(_errorCode),
                           @"schoolId": @(_schoolId),
                           @"classId": @(_classId),
                           @"scheduleId": @(_scheduleId),
                           @"timestamp": @(_timestamp),
                           @"week": _week};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

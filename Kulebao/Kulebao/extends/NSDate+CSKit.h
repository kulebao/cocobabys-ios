//
//  NSDate+CSKit.h
//  CSKit
//
//  Created by xin.c.wang on 13-4-28.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CSKit)

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

- (NSString*)isoDateString;
- (NSString*)isoDateTimeString;
- (NSString*)shortDateTimeString;

//返回周日的的开始时间
- (NSDate *)beginningOfWeek;

//返回该月的第一天
- (NSDate *)beginningOfMonth;

//该月的最后一天
- (NSDate *)endOfMonth;

@end

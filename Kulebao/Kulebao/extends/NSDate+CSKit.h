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

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;

- (NSString*)isoDateString;
- (NSString*)isoDateTimeString;

- (NSString*)zhCnDateString;
- (NSString*)zhCnDateTimeString;

- (NSString*)shortDateTimeString;

//返回周日的的开始时间
- (NSDate *)beginningOfWeek;

//返回该月的第一天
- (NSDate *)beginningOfMonth;

//该月的最后一天
- (NSDate *)endOfMonth;

//获取日
- (NSUInteger)getDay;

//获取月
- (NSUInteger)getMonth;

//获取年
- (NSUInteger)getYear;

//month个月后的日期
- (NSDate *)dateafterMonth:(int)month;

- (NSString*)string;

@end

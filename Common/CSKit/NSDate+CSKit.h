// NSDate+CSKit.h
//
// Copyright (c) 2014-2016 Xinus Wang. All rights reserved.
// https://github.com/xinus/CSKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

- (NSString*)timestampString;

- (NSString*)timestampStringZhCN;

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

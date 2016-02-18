//
//  CBChildInfo.m
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBChildInfo.h"
#import "CSKuleCommon.h"

@implementation CBChildInfo

- (NSString *)displayNick {
    NSString* trimmedNick = [_nick length]> kKuleNickMaxLength ? [_nick substringToIndex:kKuleNickMaxLength] : _nick;
    return trimmedNick ? trimmedNick : @"";
}

- (NSString *)displayAge {
    // 计算宝宝年龄
    NSDate* dayOfBirth = [NSDate dateFromString:_birthday withFormat:[NSDate dateFormatString]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* ageComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dayOfBirth toDate:[NSDate date] options:0];
    return [NSString stringWithFormat:@"%@岁%@个月", @([ageComponents year]), @([ageComponents month])];
}

@end

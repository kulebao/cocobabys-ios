//
//  CBChildInfo.m
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBChildInfo.h"
#import "CSKuleCommon.h"
#import "NSDate+CSKit.h"

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

- (BOOL)isEqual:(id)object {
    BOOL ok = NO;
    if ([object isKindOfClass:[CBChildInfo class]]) {
        CBChildInfo* nObj = object;
        ok = [self.child_id isEqualToString:nObj.child_id] && [self.school_id isEqualToNumber:nObj.school_id] && [self.class_id isEqualToNumber:nObj.class_id];
    }
    else {
        ok = [super isEqual:object];
    }
    
    return ok;
}

@end

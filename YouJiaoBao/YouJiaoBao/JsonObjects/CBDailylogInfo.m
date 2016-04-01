//
//  CBDailylogInfo.m
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBDailylogInfo.h"

@implementation CBDailylogInfo

- (BOOL)isToday {
    BOOL ok = NO;
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:self.timestamp.longLongValue / 1000];
    if ([timestamp.isoDateString isEqualToString:[[NSDate date] isoDateString]]) {
        ok = YES;
    }
    
    return ok;
}

@end

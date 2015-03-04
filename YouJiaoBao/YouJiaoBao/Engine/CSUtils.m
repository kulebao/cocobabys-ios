//
//  CSUtils.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-9.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSUtils.h"

@implementation CSUtils

+ (NSString*)stringFromDateStyle1:(NSDate*)date {
    NSString* str = nil;
    if (date) {
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MM月dd日 HH:mm";
        fmt.timeZone = [NSTimeZone localTimeZone];
        str = [fmt stringFromDate:date];
    }
    
    return str;
}

@end

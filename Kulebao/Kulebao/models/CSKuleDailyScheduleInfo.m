//
//  CSKuleDailyScheduleInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-17.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleDailyScheduleInfo.h"

@implementation CSKuleDailyScheduleInfo

@synthesize am = _am;
@synthesize pm = _pm;

- (NSString*)description {
    NSDictionary* meta = @{@"am": _am,
                           @"pm": _pm};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

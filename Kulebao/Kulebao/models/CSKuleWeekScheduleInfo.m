//
//  CSKuleWeekScheduleInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-17.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleWeekScheduleInfo.h"

@implementation CSKuleWeekScheduleInfo
@synthesize mon = _mon;
@synthesize tue = _tue;
@synthesize wed = _wed;
@synthesize thu = _thu;
@synthesize fri = _fri;

- (NSString*)description {
    NSDictionary* meta = @{@"mon": _mon,
                           @"tue": _tue,
                           @"wed": _wed,
                           @"thu": _thu,
                           @"fri": _fri};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

//
//  CSKuleSchoolInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleSchoolInfo.h"

@implementation CSKuleSchoolInfo

@synthesize schoolId = _schoolId;
@synthesize timestamp = _timestamp;
@synthesize phone = _phone;
@synthesize desc = _desc;
@synthesize schoolLogoUrl = _schoolLogoUrl;
@synthesize name = _name;

- (NSString*)description {
    NSDictionary* meta = @{@"schoolId": @(_schoolId),
                           @"timestamp": @(_timestamp),
                           @"phone": _phone,
                           @"desc": _desc,
                           @"schoolLogoUrl": _schoolLogoUrl,
                           @"name": _name};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

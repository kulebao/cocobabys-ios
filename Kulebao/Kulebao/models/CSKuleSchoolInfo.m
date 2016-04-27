//
//  CSKuleSchoolInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleSchoolInfo.h"

@implementation CSKuleSchoolInfo

@synthesize schoolId = _schoolId;
@synthesize timestamp = _timestamp;
@synthesize phone = _phone;
@synthesize desc = _desc;
@synthesize schoolLogoUrl = _schoolLogoUrl;
@synthesize name = _name;
@synthesize fullName = _fullName;
@synthesize address = _address;
@synthesize properties = _properties;
@synthesize token = _token;

- (BOOL)hasProperty:(NSString*)key {
    BOOL ret = NO;
    
    for (NSDictionary* propertyInfo in _properties) {
        if (key && [propertyInfo[@"name"] isEqualToString:key]) {
            ret = [propertyInfo[@"value"] boolValue];
            break;
        }
    }
    
    return ret;
}

- (NSString*)description {
    NSDictionary* meta = @{@"schoolId": @(_schoolId),
                           @"timestamp": @(_timestamp),
                           @"phone": _phone,
                           @"desc": _desc,
                           @"schoolLogoUrl": _schoolLogoUrl,
                           @"name": _name,
                           @"fullName" : _fullName,
                           @"address" : _address,
                           @"properties" : _properties,
                           @"token" : _token};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

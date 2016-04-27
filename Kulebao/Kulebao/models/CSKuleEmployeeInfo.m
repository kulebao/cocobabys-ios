//
//  CSKuleEmployeeInfo.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-8.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleEmployeeInfo.h"

@implementation CSKuleEmployeeInfo

@synthesize employeeId = _employeeId;
@synthesize name = _name;
@synthesize phone = _phone;
@synthesize gender = _gender;
@synthesize workgroup = _workgroup;
@synthesize workduty = _workduty;
@synthesize portrait = _portrait;
@synthesize birthday = _birthday;
@synthesize schoolId = _schoolId;
@synthesize timestamp = _timestamp;
@synthesize privilegeGroup = _privilegeGroup;

- (NSString*)description {
    NSDictionary* meta = @{@"employeeId": _employeeId,
                           @"name": _name,
                           @"phone": _phone,
                           @"gender": @(_gender),
                           @"workgroup": _workgroup,
                           @"workduty": _workduty,
                           @"portrait": _portrait,
                           @"loginName": _loginName,
                           @"birthday": _birthday,
                           @"schoolId": @(_schoolId),
                           @"timestamp": @(_timestamp),
                           @"privilegeGroup": _privilegeGroup
                           };
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

//
//  CSKuleParentInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleParentInfo.h"

@implementation CSKuleParentInfo
@synthesize parentId = _parentId;
@synthesize schoolId = _schoolId;
@synthesize name = _name;
@synthesize phone = _phone;
@synthesize portrait = _portrait;
@synthesize gender = _gender;
@synthesize birthday = _birthday;
@synthesize timestamp = _timestamp;
@synthesize memberStatus = _memberStatus;
@synthesize status = _status;
@synthesize company = _company;

- (id)copyWithZone:(NSZone *)zone {
    CSKuleParentInfo* newObj =  [[[self class] allocWithZone:zone] init];
    
    newObj.parentId = self.parentId;
    newObj.schoolId = self.schoolId;
    newObj.name = self.name;
    newObj.phone = self.phone;
    newObj.portrait = self.portrait;
    newObj.gender = self.gender;
    newObj.birthday = self.birthday;
    newObj.timestamp = self.timestamp;
    newObj.memberStatus = self.memberStatus;
    newObj.status = self.status;
    newObj.company = self.company;
    
    return newObj;
}

- (NSString*)description {
    NSDictionary* meta = @{@"parentId": _parentId,
                           @"schoolId": @(_schoolId),
                           @"name": _name,
                           @"phone": _phone,
                           @"portrait": _portrait,
                           @"gender": @(_gender),
                           @"birthday": _birthday,
                           @"timestamp": @(_timestamp),
                           @"memberStatus": @(_memberStatus),
                           @"status": @(_status),
                           @"company": _company ? _company : @"",
                           };
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

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

- (NSString*)description {
    NSDictionary* meta = @{@"parentId": _parentId,
                           @"schoolId": @(_schoolId),
                           @"name": _name,
                           @"phone": _phone,
                           @"portrait": _portrait,
                           @"gender": @(_gender),
                           @"birthday": _birthday};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

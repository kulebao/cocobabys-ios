//
//  CSKuleBindInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleBindInfo.h"

@implementation CSKuleBindInfo

@synthesize accessToken = _accessToken;
@synthesize accountName = _accountName;
@synthesize schoolName = _schoolName;
@synthesize username = _username;
@synthesize schoolId = _schoolId;
@synthesize errorCode = _errorCode;
@synthesize memberStatus = _memberStatus;

- (NSString*)description {
    NSDictionary* meta = @{@"accessToken": _accessToken,
                           @"accountName": _accountName,
                           @"schoolName": _schoolName,
                           @"username": _username,
                           @"schoolId": @(_schoolId),
                           @"errorCode": @(_errorCode),
                           @"memberStatus": _memberStatus,
                           @"im_token": SAFE_OBJECT(_imToken)};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

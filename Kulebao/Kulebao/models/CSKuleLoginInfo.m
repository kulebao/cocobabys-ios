//
//  CSKuleLoginInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleLoginInfo.h"

@implementation CSKuleLoginInfo

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
                           @"memberStatus": _memberStatus ? _memberStatus : @"",
                           @"imToken": SAFE_STRING(_imToken)};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

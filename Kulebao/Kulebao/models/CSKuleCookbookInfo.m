//
//  CSKuleCookbookInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCookbookInfo.h"

@implementation CSKuleCookbookInfo

@synthesize errorCode = _errorCode;
@synthesize schoolId = _schoolId;
@synthesize cookbookId = _cookbookId;
@synthesize timestamp = _timestamp;
@synthesize extraTip = _extraTip;

@synthesize mon = _mon;
@synthesize tue = _tue;
@synthesize wed = _wed;
@synthesize thu = _thu;
@synthesize fri = _fri;

- (NSString*)description {
    NSDictionary* meta = @{@"errorCode": @(_errorCode),
                           @"schoolId": @(_schoolId),
                           @"cookbookId": @(_cookbookId),
                           @"timestamp": @(_timestamp),
                           @"extraTip": _extraTip,
                           @"mon": _mon,
                           @"tue": _tue,
                           @"wed": _wed,
                           @"thu": _thu,
                           @"fri": _fri};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

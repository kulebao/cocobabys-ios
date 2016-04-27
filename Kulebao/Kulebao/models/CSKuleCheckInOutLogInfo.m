//
//  CSKuleCheckInOutLogInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleCheckInOutLogInfo.h"

@implementation CSKuleCheckInOutLogInfo

@synthesize timestamp = _timestamp;
@synthesize noticeType = _noticeType;
@synthesize childId = _childId;
@synthesize pushId = _pushId;
@synthesize recordUrl = _recordUrl;
@synthesize parentName = _parentName;
@synthesize deviceType = _deviceType;

- (NSString*)description {
    NSDictionary* meta = @{@"timestamp": @(_timestamp),
                           @"noticeType": @(_noticeType),
                           @"childId": _childId,
                           @"pushId": _pushId ? _pushId : @"",
                           @"recordUrl": _recordUrl,
                           @"parentName": _parentName,
                           @"deviceType": @(_deviceType)};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

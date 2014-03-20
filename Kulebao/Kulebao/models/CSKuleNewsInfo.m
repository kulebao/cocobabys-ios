//
//  CSKuleNewsInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsInfo.h"

@implementation CSKuleNewsInfo

@synthesize newsId = _newsId;
@synthesize schoolId = _schoolId;
@synthesize classId = _classId;
@synthesize title = _title;
@synthesize content = _content;
@synthesize timestamp = _timestamp;
@synthesize published = _published;
@synthesize noticeType = _noticeType;


- (NSString*)description {
    NSDictionary* meta = @{@"newsId": @(_newsId),
                           @"schoolId": @(_schoolId),
                           @"classId": @(_classId),
                           @"title": _title,
                           @"content": _content,
                           @"timestamp": @(_timestamp),
                           @"published": @(_published),
                           @"noticeType": @(_noticeType)};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

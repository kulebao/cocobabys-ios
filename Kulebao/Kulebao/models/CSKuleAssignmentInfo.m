//
//  CSKuleAssignmentInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-12.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleAssignmentInfo.h"

@implementation CSKuleAssignmentInfo

@synthesize assignmentId = _assignmentId;
@synthesize timestamp = _timestamp;
@synthesize title = _title;
@synthesize content = _content;
@synthesize publisher = _publisher;
@synthesize iconUrl = _iconUrl;
@synthesize classId = _classId;

- (NSString*)description {
    NSDictionary* meta = @{@"assignmentId": @(_assignmentId),
                           @"timestamp": @(_timestamp),
                           @"title": _title,
                           @"content": _content,
                           @"publisher": _publisher,
                           @"iconUrl": _iconUrl,
                           @"classId": @(_classId)
                           };
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

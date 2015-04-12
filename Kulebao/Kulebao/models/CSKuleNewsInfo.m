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
@synthesize image = _image;
@synthesize publisherId = _publisherId;
@synthesize feedbackRequired = _feedbackRequired;
@synthesize tags = _tags;

- (BOOL)containsTag:(NSString*)tag {
    BOOL ret = NO;
    if (tag.length > 0) {
        ret = [_tags containsObject:tag];
    }
    return ret;
}

- (BOOL)isSendingMark {
    return NO;
}

- (void)markAsRead {
    self.feedbackRequired = NO;
    
    [self noticeUpdate];
}

- (NSString*)description {
    NSDictionary* meta = @{@"newsId": @(_newsId),
                           @"schoolId": @(_schoolId),
                           @"classId": @(_classId),
                           @"title": _title,
                           @"content": _content,
                           @"timestamp": @(_timestamp),
                           @"published": @(_published),
                           @"noticeType": @(_noticeType),
                           @"publisherId": _publisherId,
                           @"feedbackRequired": @(_feedbackRequired),
                           @"tags": _tags};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

- (void)noticeUpdate {
    if ([self.delegate respondsToSelector:@selector(newsInfoDataUpdated:)]) {
        [self.delegate newsInfoDataUpdated:self];
    }
}

@end

//
//  CSKuleNewsInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsInfo.h"
#import "CSAppDelegate.h"
#import "CSKuleInterpreter.h"

@interface CSKuleNewsInfo ()

@property (nonatomic, strong) AFHTTPRequestOperation* opMark;
@property (nonatomic, strong) AFHTTPRequestOperation* opQuery;

@end

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

@synthesize opMark = _opMark;
@synthesize opQuery = _opQuery;
@synthesize status = _status;

- (BOOL)containsTag:(NSString*)tag {
    BOOL ret = NO;
    if (tag.length > 0) {
        ret = [_tags containsObject:tag];
    }
    return ret;
}

- (NSString*)tagTitle {
    NSString* tTitle = @"园内公告";
    if ([self containsTag:@"作业"]) {
        tTitle = @"亲子作业";
    }
    else if(self.classId > 0) {
        tTitle = @"班级通知";
    }
    
    return tTitle;
}

- (BOOL)isSendingMark {
    return self.status == kNewsStatusMarking;
}

- (void)reloadStatus {
    if (self.feedbackRequired) {
        if ([gApp.engine.preferences hasMarkedNews:self]) {
            self.status = kNewsStatusRead;
            [self noticeUpdate];
        }
        else if(self.status == kNewsStatusUnknown || self.status == kNewsStatusUnread) {
            [self queryReadStatus];
        }
    }
}

- (void)markAsRead {
    if (!self.feedbackRequired) {
        return;
    }
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        if ([operation isEqual:self.opMark]) {
            self.opMark = nil;
            self.status = kNewsStatusRead;
            //[gApp.engine.preferences markNews:self];
            [self noticeUpdate];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        if ([operation isEqual:self.opMark]) {
            self.opMark = nil;
            self.status = kNewsStatusUnknown;
            [self noticeUpdate];
        }
    };

    self.status = kNewsStatusMarking;
    if (self.opMark) {
        [self.opMark cancel];
    }
    self.opMark = [gApp.engine reqMarkAsRead:self
                                    byParent:gApp.engine.currentRelationship.parent
                                     success:sucessHandler
                                     failure:failureHandler];
    [self noticeUpdate];
}

- (void)queryReadStatus {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        if([operation isEqual:self.opQuery]) {
            self.opQuery = nil;
            CSKuleParentInfo* reader = [CSKuleInterpreter decodeParentInfo:dataJson];
            if ([reader.parentId isEqualToString:gApp.engine.currentRelationship.parent.parentId]) {
                self.status = kNewsStatusRead;
                [gApp.engine.preferences markNews:self];
            }
            else {
                self.status = kNewsStatusUnknown;
            }
            
            self.opQuery = nil;
            [self noticeUpdate];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        if([operation isEqual:self.opQuery]) {
            self.opQuery = nil;
            self.status = kNewsStatusUnknown;
            [self noticeUpdate];
        }
    };
    
    self.status = kNewsStatusQuerying;
    if (self.opQuery) {
        [self.opQuery cancel];
    }
    self.opQuery = [gApp.engine reqQueryReadStatusOf:self
                                            byParent:gApp.engine.currentRelationship.parent
                                             success:sucessHandler
                                             failure:failureHandler];
    [self noticeUpdate];
    
}

- (NSString*)description {
    NSDictionary* meta = @{@"newsId": @(_newsId),
                           @"schoolId": @(_schoolId),
                           @"classId": @(_classId),
                           @"title": _title,
                           @"content": _content,
                           @"timestamp": @(_timestamp*1000),
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

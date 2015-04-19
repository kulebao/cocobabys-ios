//
//  CSKuleNewsInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kNewsStatusUnknown,
    kNewsStatusRead,
    kNewsStatusUnread,
    kNewsStatusMarking,
    kNewsStatusQuerying,
}NewsStatus;

@class CSKuleNewsInfo;
@protocol CSKuleNewsInfoDelegate <NSObject>
@optional
- (void)newsInfoDataUpdated:(CSKuleNewsInfo*)newsInfo;
@end

@interface CSKuleNewsInfo : NSObject

/*
 {
 "news_id":11,
 "school_id":93740362,
 "title":"通知14",
 "content":"测试信息",
 "timestamp":1426691242108,
 "published":true,
 "notice_type":2,
 "class_id":0,
 "image":"",
 "publisher_id":"3_93740362_3344",
 "feedback_required":false,
 "tags":["作业","活动"]
 }
 */
@property (nonatomic, assign) NSInteger newsId;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger classId;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* image;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) BOOL published;
@property (nonatomic, assign) NSInteger noticeType;
@property (nonatomic, strong) NSString* publisherId;
@property (nonatomic, assign) BOOL feedbackRequired;
@property (nonatomic, strong) NSArray* tags;

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, weak) id delegate;

- (BOOL)containsTag:(NSString*)tag;
- (NSString*)tagTitle;

- (BOOL)isSendingMark;
- (void)markAsRead;
- (void)reloadStatus;
- (void)queryReadStatus;

@end

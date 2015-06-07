//
//  EntityNewsInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-17.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityNewsInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * classId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSNumber * noticeType;
@property (nonatomic, retain) NSNumber * published;
@property (nonatomic, retain) NSString * publisherId;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, assign) NSNumber * feedbackRequired;
@property (nonatomic, strong) NSString* tags;

@end

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
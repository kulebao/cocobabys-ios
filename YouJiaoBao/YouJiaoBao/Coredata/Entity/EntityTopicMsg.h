//
//  EntityTopicMsg.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-17.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EntityChildInfo;

@interface EntityTopicMsg : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSString * medium;
@property (nonatomic, retain) NSString * senderId;
@property (nonatomic, retain) NSString * senderType;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) EntityChildInfo *childInfo;

@end

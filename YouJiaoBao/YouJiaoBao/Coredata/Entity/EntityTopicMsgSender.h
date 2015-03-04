//
//  EntityTopicMsgSender.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-10-11.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityTopicMsgSender : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * portrait;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * timestamp;

@end

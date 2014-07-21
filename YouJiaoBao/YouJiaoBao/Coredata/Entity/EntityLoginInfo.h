//
//  EntityLoginInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-21.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityLoginInfo : NSManagedObject

@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * loginName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * portrait;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * workduty;
@property (nonatomic, retain) NSString * workgroup;
@property (nonatomic, retain) NSDate * loginDate;

@end

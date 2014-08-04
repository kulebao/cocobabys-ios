//
//  EntityChildInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-4.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityChildInfo : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * childId;
@property (nonatomic, retain) NSNumber * classId;
@property (nonatomic, retain) NSString * classname;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nick;
@property (nonatomic, retain) NSString * portrait;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * timestamp;

@end

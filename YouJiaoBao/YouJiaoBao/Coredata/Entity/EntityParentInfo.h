//
//  EntityParentInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityParentInfo : NSManagedObject

@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSNumber * memberStatus;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * portrait;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * timestamp;

@end

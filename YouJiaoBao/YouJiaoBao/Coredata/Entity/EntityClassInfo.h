//
//  EntityClassInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-21.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityClassInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * classId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * employeeId;

@end

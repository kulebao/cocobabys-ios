//
//  EntityAssignmentInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-10.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityAssignmentInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSNumber * classId;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * read;

@end

//
//  EntityAssessInfo.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-3.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityAssessInfo : NSManagedObject

@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * dining;
@property (nonatomic, retain) NSNumber * emotion;
@property (nonatomic, retain) NSNumber * rest;
@property (nonatomic, retain) NSNumber * activity;
@property (nonatomic, retain) NSNumber * game;
@property (nonatomic, retain) NSNumber * exercise;
@property (nonatomic, retain) NSNumber * selfCare;
@property (nonatomic, retain) NSNumber * manner;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * childId;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * uid;

@end

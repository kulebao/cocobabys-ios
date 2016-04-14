//
//  ModelAssessment.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-1.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelAssessment : NSObject

@property (nonatomic, strong) NSString* comments;
@property (nonatomic, strong) NSString* childId;
@property (nonatomic, assign) NSInteger emotion;
@property (nonatomic, assign) NSInteger dining;
@property (nonatomic, assign) NSInteger rest;
@property (nonatomic, assign) NSInteger activity;
@property (nonatomic, assign) NSInteger game;
@property (nonatomic, assign) NSInteger exercise;
@property (nonatomic, assign) NSInteger selfCare;
@property (nonatomic, assign) NSInteger manner;
@end

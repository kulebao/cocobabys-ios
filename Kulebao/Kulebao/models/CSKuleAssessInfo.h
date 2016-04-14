//
//  CSKuleAssessInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-26.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleAssessInfo : NSObject
@property (nonatomic, assign) NSInteger assessId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString* publisher;
@property (nonatomic, strong) NSString* comments;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, strong) NSString* childId;
@property (nonatomic, assign) NSInteger emotion;
@property (nonatomic, assign) NSInteger dining;
@property (nonatomic, assign) NSInteger rest;
@property (nonatomic, assign) NSInteger activity;
@property (nonatomic, assign) NSInteger game;
@property (nonatomic, assign) NSInteger exercise;
@property (nonatomic, assign) NSInteger selfcare;
@property (nonatomic, assign) NSInteger manner;

@end

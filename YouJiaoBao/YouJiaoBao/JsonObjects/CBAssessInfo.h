//
//  CBAssessInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBAssessInfo : CSJsonObject

@property (nonatomic, strong) NSString* child_id;
@property (nonatomic, strong) NSString* comments;
@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSNumber* school_id;

@property (nonatomic, strong) NSNumber* activity;
@property (nonatomic, strong) NSNumber* dining;
@property (nonatomic, strong) NSNumber* emotion;
@property (nonatomic, strong) NSNumber* exercise;
@property (nonatomic, strong) NSNumber* game;
@property (nonatomic, strong) NSNumber* manner;
@property (nonatomic, strong) NSNumber* self_care;
@property (nonatomic, strong) NSNumber* rest;

@property (nonatomic, strong) NSString* publisher;
@property (nonatomic, strong) NSNumber* timestamp;

@end

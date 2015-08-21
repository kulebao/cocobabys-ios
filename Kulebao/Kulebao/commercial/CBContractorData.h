//
//  CBContractorData.h
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityData.h"

@interface CBContractorData : CSJsonEntityData

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger agent_id;
@property (nonatomic, assign) NSInteger contractor_id;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* contact;
@property (nonatomic, strong) NSString* time_span;
@property (nonatomic, strong) NSString* detail;
@property (nonatomic, strong) NSArray* logos;
@property (nonatomic, assign) NSInteger updated_at;
@property (nonatomic, strong) CBPublishData* publishing;
@property (nonatomic, strong) CBPriceData* price;
@property (nonatomic, assign) NSInteger priority;

@end

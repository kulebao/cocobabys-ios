//
//  CSKuleBusLocationInfo.h
//  youlebao
//
//  Created by xin.c.wang on 15/7/5.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 {
 address = "\U56db\U5ddd\U7701\U6210\U90fd\U5e02\U53cc\U6d41\U53bf\U5143\U666f\U8def";
 "child_id" = "2_9028_52049";
 direction = "-1";
 "driver_id" = "3_9028_1428477866424";
 latitude = "30.53457";
 longitude = "104.055455";
 onBoard = 0;
 radius = "62.91685485839844";
 "school_id" = 9028;
 status = 1;
 timestamp = 1436106433250;
 }
 */

@interface CSKuleBusLocationInfo : NSObject

@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* childId;
@property (nonatomic, assign) NSInteger direction;
@property (nonatomic, strong) NSString* driverId;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) NSInteger onBoard;
@property (nonatomic, assign) NSInteger radius;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSTimeInterval timestamp;


@end

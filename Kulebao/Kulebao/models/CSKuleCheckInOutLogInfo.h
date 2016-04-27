//
//  CSKuleCheckInOutLogInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleCheckInOutLogInfo : NSObject

@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) NSInteger noticeType;
@property (nonatomic, strong) NSString* childId;
@property (nonatomic, strong) NSString* pushId;
@property (nonatomic, strong) NSString* recordUrl;
@property (nonatomic, strong) NSString* parentName;
@property (nonatomic, assign) NSInteger deviceType;

@end

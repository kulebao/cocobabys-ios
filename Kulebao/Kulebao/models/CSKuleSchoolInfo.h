//
//  CSKuleSchoolInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleSchoolInfo : NSObject

@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* desc;
@property (nonatomic, strong) NSString* schoolLogoUrl;
@property (nonatomic, strong) NSString* name;

@end

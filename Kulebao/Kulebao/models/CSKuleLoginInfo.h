//
//  CSKuleLoginInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleLoginInfo : NSObject

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* accountName;
@property (nonatomic, strong) NSString* schoolName;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString* memberStatus;

@end

//
//  CSKulePreferences.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSKuleLoginInfo.h"

@interface CSKulePreferences : NSObject
@property (nonatomic, strong) NSString* defaultUsername;
@property (nonatomic, assign) BOOL guideShown;

@property (nonatomic, strong) NSString* loginUsername;
@property (nonatomic, strong) CSKuleLoginInfo* loginInfo;

+ (id)defaultPreferences;

@end

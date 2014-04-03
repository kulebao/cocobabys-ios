//
//  CSKulePreferences.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSKuleLoginInfo.h"
#import "CSKuleBPushInfo.h"

@interface CSKulePreferences : NSObject
@property (nonatomic, strong) NSData* deviceToken;

@property (nonatomic, strong) NSString* defaultUsername;
@property (nonatomic, assign) BOOL guideShown;

@property (nonatomic, strong) CSKuleBPushInfo* baiduPushInfo;
@property (nonatomic, strong) CSKuleLoginInfo* loginInfo;
@property (nonatomic, strong, readonly) NSMutableDictionary* historyAccounts; // {mobile:date,}

+ (id)defaultPreferences;

- (void)addHistoryAccount:(NSString*)account;

@end

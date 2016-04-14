//
//  CSEngine.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelAccount.h"
#import "CBSessionDataModel.h"

extern NSString* kNotiLoginSuccess;
extern NSString* kNotiLogoutSuccess;
extern NSString* kNotiUnauthorized;
extern NSString* kNotiShowLogin;

extern NSString* kAppleID;

@interface CSEngine : NSObject

+ (id)sharedInstance;

- (void)setupAppearance;
- (void)setupBaiduMobStat;
- (void)onLoadClassInfoList:(NSArray*)classInfoList;
- (BOOL)encryptAccount:(ModelAccount*)account;
- (ModelAccount*)decryptAccount;
- (BOOL)clearAccount;

@end

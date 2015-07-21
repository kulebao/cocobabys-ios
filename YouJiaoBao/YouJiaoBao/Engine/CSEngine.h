//
//  CSEngine.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityLoginInfo.h"
#import "ModelAccount.h"

extern NSString* kNotiLoginSuccess;
extern NSString* kNotiLogoutSuccess;
extern NSString* kNotiUnauthorized;
extern NSString* kNotiShowLogin;

extern NSString* kAppleID;

@interface CSEngine : NSObject
@property (nonatomic, strong, readonly) EntityLoginInfo* loginInfo;
@property (nonatomic, strong, readonly) NSArray* classInfoList;

+ (id)sharedInstance;

- (void)setupAppearance;

- (void)onLogin:(EntityLoginInfo*)loginInfo;

- (void)onLoadClassInfoList:(NSArray*)classInfoList;

- (BOOL)encryptAccount:(ModelAccount*)account;

- (ModelAccount*)decryptAccount;

- (BOOL)clearAccount;

@end

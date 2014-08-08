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
extern NSString* kNotiUnauthorized;


@interface CSEngine : NSObject
@property (nonatomic, strong, readonly) EntityLoginInfo* loginInfo;

+ (id)sharedInstance;

- (BOOL)encryptAccount:(ModelAccount*)account;

- (ModelAccount*)decryptAccount;

- (BOOL)clearAccount;

- (void)onLogin:(EntityLoginInfo*)loginInfo;

@end

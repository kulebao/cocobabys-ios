//
//  NSString+CSKit.h
//  youlebao
//
//  Created by xin.c.wang on 14-4-8.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CSKit)

- (BOOL)isValidPswd;
- (BOOL)isValidMobile;
- (BOOL)isValidSmsCode;
- (BOOL)isValidCardNum;
- (NSString*)trim;

- (NSString *)MD5Hash;
- (NSString *)MD5HashEx;

@end

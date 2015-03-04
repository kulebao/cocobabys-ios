//
//  NSString+CSKit.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-8.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#import "NSString+CSKit.h"

@implementation NSString (CSKit)

- (BOOL)isValidPswd {
    NSString *regex =@"^[a-zA-Z0-9]{6,16}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}

- (BOOL)isValidMobile {
    NSString *regex =@"^((\\+86)|(86))?(1)\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}

- (BOOL)isValidSmsCode {
    NSString *regex =@"^\\d{6}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}

@end

//
//  NSString+CSKit.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-8.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#import "NSString+CSKit.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (CSKit)

// 检查密码格式是否正确,6-16位，数字或英文字母
- (BOOL)isValidPswd {
    NSString *regex =@"^[a-zA-Z0-9]{6,16}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}

// 简单判断一下是否是手机号码
// 判断依据，1开头的11位数字
- (BOOL)isValidMobile {
    NSString *regex =@"^((\\+86)|(86))?(1)\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}

// 判断验证码是否合法，6位数字
- (BOOL)isValidSmsCode {
    NSString *regex =@"^\\d{6}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}


// 简单判断一下是否是合法卡号
// 判断依据，10位数字
- (BOOL)isValidCardNum {
    NSString *regex =@"^\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:self];
    return ret;
}

- (NSString*)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)MD5Hash {
    if(self.length == 0) {
        return nil;
    }
    
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

- (NSString *)MD5HashEx {
    return [[self MD5Hash] stringByAppendingString: self.lastPathComponent];
}

@end

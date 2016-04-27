// NSString+CSKit.m
//
// Copyright (c) 2014-2016 Xinus Wang. All rights reserved.
// https://github.com/xinus/CSKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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

// CSTextFieldDelegate.m
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

#import "CSTextFieldDelegate.h"

@implementation CSTextFieldDelegate {
    NSInteger _type;
}

@synthesize maxLength = _maxLength;

- (id)initWithType:(NSInteger)type {
    if (self = [self init]) {
        _type = type;
        _maxLength = -1;
    }
    return self;
}

- (BOOL)isNumber:(NSString*)str {
    if (str.length == 0) {
        return YES;
    }
    NSString *regex =@"[0-9\n]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:str];
    return ret;
}

- (BOOL)isNationalID:(NSString*)str {
    if (str.length == 0) {
        return YES;
    }
    NSString *regex =@"[0-9Xx\n]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL ret = [predicate evaluateWithObject:str];
    return ret;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL ret = YES;
    switch (_type) {
        case kCSTextFieldDelegateNumberOnly:
            ret = [self isNumber:string];
            break;
        case kCSTextFieldDelegateNationalID:
            ret = [self isNationalID:string];
            break;
        case kCSTextFieldDelegateNormal:
            break;
        default:
            break;
    }
    
    if (self.maxLength >=0 && string.length>0) {
        ret = (textField.text.length < self.maxLength);
    }
    
    return ret;
}

@end

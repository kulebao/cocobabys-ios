//
//  CSTextFieldDelegate.m
//  CSKit
//
//  Created by xin.c.wang on 13-9-25.
//  Copyright (c) 2013年 CSKit. All rights reserved.
//

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
    BOOL ok = YES;
    switch (_type) {
        case kCSTextFieldDelegateNumberOnly:
            ok = [self isNumber:string];
            break;
        case kCSTextFieldDelegateNationalID:
            ok = [self isNationalID:string];
            break;
        case kCSTextFieldDelegateNormal:
            break;
        default:
            break;
    }

    if (self.maxLength > 0 && string.length>0) {
        NSString* oldText = textField.text;
        NSString* newText = [oldText stringByReplacingCharactersInRange:range withString:string];
        ok = (newText.length < self.maxLength);
        if (!ok) {
            textField.text = [newText substringWithRange:NSMakeRange(0, self.maxLength)];
        }
    }
    
    return ok;
}

@end

//
//  CSTextFieldDelegate.m
//  CSKit
//
//  Created by xin.c.wang on 13-9-25.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import "CSTextFieldDelegate.h"

@implementation CSTextFieldDelegate {
    NSInteger _type;
}

- (id)initWithType:(NSInteger)type {
    if (self = [self init]) {
        _type = type;
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
        default:
            break;
    }
    
    return ret;
}

@end

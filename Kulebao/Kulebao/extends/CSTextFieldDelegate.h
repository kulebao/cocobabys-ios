//
//  CSTextFieldDelegate.h
//  CSKit
//
//  Created by xin.c.wang on 13-9-25.
//  Copyright (c) 2013年 CSKit. All rights reserved.
//

#import <Foundation/Foundation.h>

enum CSTextFieldDelegateType {
    kCSTextFieldDelegateNormal = 0,
    kCSTextFieldDelegateNumberOnly = 1,
    kCSTextFieldDelegateNationalID = 2,
};

@interface CSTextFieldDelegate : NSObject <UITextFieldDelegate>

- (id)initWithType:(NSInteger)type;

@property (nonatomic, assign) NSInteger maxLength;

@end

//
//  CSKit.h
//  CSKit
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#ifndef CSKit_CSKit_h
#define CSKit_CSKit_h

#import "CSTextFieldDelegate.h"
#import "NSDictionary+CSKit.h"
#import "UIViewController+CSKit.h"

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#define UIColorRGB(r,g,b) \
([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0])

#ifdef DEBUG
#define CSLog NSLog
#else
#define CSLog (void)
#endif

#endif

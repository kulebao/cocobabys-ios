//
//  CSKit.h
//  CSKit
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 CSKit. All rights reserved.
//

#ifndef CSKit_CSKit_h
#define CSKit_CSKit_h

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#define UIColorRGB(r,g,b) \
([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0])

#ifdef DEBUG
#define CSLog NSLog
#else
#define CSLog (void)
#endif


#import "CSTextFieldDelegate.h"
#import "NSDictionary+CSKit.h"
#import "UIViewController+CSKit.h"
#import "NSDate+CSKit.h"
#import "UIWebView+CSKit.h"
#import "NSURL+CSKit.h"

#endif

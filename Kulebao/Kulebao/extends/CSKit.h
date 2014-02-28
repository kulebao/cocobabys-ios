//
//  CSKit.h
//  CSKit
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#ifndef Kulebao_CSKit_h
#define Kulebao_CSKit_h

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#ifdef DEBUG
#define CSLog NSLog
#else
#define CSLog (void)
#endif

#endif

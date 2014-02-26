//
//  CSLog.h
//  CSKit
//
//  Created by xin.c.wang on 14-2-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#ifndef Kulebao_CSLog_h
#define Kulebao_CSLog_h

#ifdef DEBUG
#define CSLog NSLog
#else
#define CSLog (void)
#endif

#endif

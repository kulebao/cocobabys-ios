//
//  CSKuleWeekScheduleInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKuleDailyScheduleInfo.h"

@interface CSKuleWeekScheduleInfo : NSObject

@property (nonatomic, strong) CSKuleDailyScheduleInfo* mon;
@property (nonatomic, strong) CSKuleDailyScheduleInfo* tue;
@property (nonatomic, strong) CSKuleDailyScheduleInfo* wed;
@property (nonatomic, strong) CSKuleDailyScheduleInfo* thu;
@property (nonatomic, strong) CSKuleDailyScheduleInfo* fri;

@end

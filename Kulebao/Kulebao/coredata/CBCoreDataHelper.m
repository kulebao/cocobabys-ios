//
//  CBCoreDataHelper.m
//  youlebao
//
//  Created by WangXin on 4/8/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBCoreDataHelper.h"

@implementation CBCoreDataHelper

+ (id)sharedInstance {
    static CBCoreDataHelper* s_instance = nil;
    if (s_instance == nil) {
        s_instance = [[CBCoreDataHelper alloc] init];
        [s_instance initWithMomdName:@"Kulebao"];
    }
    
    return s_instance;
}

@end

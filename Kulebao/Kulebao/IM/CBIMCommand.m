//
//  CBIMCommand.m
//  youlebao
//
//  Created by WangXin on 5/12/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBIMCommand.h"
#import "NSString+CSKit.h"

@implementation CBIMCommand

- (BOOL)parse:(NSString*)cmdline {
    BOOL ok = NO;
    NSArray* arr = [cmdline componentsSeparatedByString:@" - "];
    if (arr.count >= 4) {
        self.cmd = arr[0];
        self.userId = arr[1];
        NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
        self.schoolId = [fmt numberFromString:arr[2]];
        self.classId = [fmt numberFromString:arr[3]];
        
        ok = YES;
    }
    
    return ok;
}

@end

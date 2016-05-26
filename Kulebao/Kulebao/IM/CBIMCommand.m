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
@synthesize userId = _userId;
@synthesize schoolId = _schoolId;
@synthesize classId = _classId;

- (BOOL)parse:(NSString*)cmdline {
    BOOL ok = NO;
    NSArray* arr = [cmdline componentsSeparatedByString:@" - "];
    if (arr.count >= 1) {
        self.cmd = arr[0];
        self.params = [arr subarrayWithRange:NSMakeRange(1, arr.count-1)];
    }
    
    if ([self.cmd isEqualToString:@"ban"] && self.params.count >= 3) {
        _userId = arr[1];
        NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
        _schoolId = [fmt numberFromString:arr[2]];
        _classId = [fmt numberFromString:arr[3]];
        ok =  YES;
    }
    else if ([self.cmd isEqualToString:@"approval"] && self.params.count >= 3) {
        _userId = arr[1];
        NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
        _schoolId = [fmt numberFromString:arr[2]];
        _classId = [fmt numberFromString:arr[3]];
        ok =  YES;
    }
    else if ([self.cmd isEqualToString:@"hidemsg"] && self.params.count >= 4) {
        _subtype = arr[1];
        _msgUid = arr[2];
        NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
        _schoolId = [fmt numberFromString:arr[3]];
        _classId = [fmt numberFromString:arr[4]];
        ok =  YES;
    }

    return ok;
}




@end

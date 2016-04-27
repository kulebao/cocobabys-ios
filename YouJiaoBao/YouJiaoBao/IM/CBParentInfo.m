//
//  CBParentInfo.m
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBParentInfo.h"

@implementation CBParentInfo

- (BOOL)isEqual:(id)object {
    BOOL ok = NO;
    if ([object isKindOfClass:[CBParentInfo class]]) {
        CBParentInfo* nObj = object;
        ok = [self.parent_id isEqualToString:nObj.parent_id] && [self.school_id isEqualToNumber:nObj.school_id];
    }
    else {
        ok = [super isEqual:object];
    }
    
    return ok;
}

@end

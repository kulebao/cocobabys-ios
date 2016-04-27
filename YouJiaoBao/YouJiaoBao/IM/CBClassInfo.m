//
//  CBClassInfo.m
//  youlebao
//
//  Created by WangXin on 12/7/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBClassInfo.h"

@implementation CBClassInfo

- (BOOL)isEqual:(id)object {
    BOOL ok = NO;
    if ([object isKindOfClass:[CBClassInfo class]]) {
        CBClassInfo* nObj = object;
        ok = (self.school_id == nObj.school_id) && (self.class_id == nObj.class_id);
    }
    else {
        ok = [super isEqual:object];
    }
    
    return ok;
}

@end

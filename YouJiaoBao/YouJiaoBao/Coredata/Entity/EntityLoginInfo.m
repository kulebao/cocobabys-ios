//
//  EntityLoginInfo.m
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//

#import "EntityLoginInfo.h"

@implementation EntityLoginInfo
@synthesize ineligibleClassList;

// Insert code here to add functionality to your managed object subclass

- (BOOL)allowToSendAll {
    BOOL ok = NO;
    if (self.ineligibleClassList && self.ineligibleClassList.count == 0) {
        ok = YES;
    }
    
    return ok;
}

@end

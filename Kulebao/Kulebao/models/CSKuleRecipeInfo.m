//
//  CSKuleRecipeInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleRecipeInfo.h"

@implementation CSKuleRecipeInfo

@synthesize breakfast = _breakfast;
@synthesize lunch = _lunch;
@synthesize dinner = _dinner;
@synthesize extra = _extra;

- (NSString*)description {
    NSDictionary* meta = @{@"breakfast": _breakfast,
                           @"tulunche": _lunch,
                           @"dinner": _dinner,
                           @"extra": _extra};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

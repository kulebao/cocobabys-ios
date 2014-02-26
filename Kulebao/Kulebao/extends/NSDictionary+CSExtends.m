//
//  NSDictionary+CSExtends.m
//  CSKit
//
//  Created by xin.c.wang on 13-4-27.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import "NSDictionary+CSExtends.h"

@implementation NSDictionary (CSExtends)

- (id)valueForKeyNotNull:(NSString *)key{
    id object = [self valueForKey:key];
    
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return object;
}

@end

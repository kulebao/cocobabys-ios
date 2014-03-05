//
//  CSKuleRelationshipInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleRelationshipInfo.h"

@implementation CSKuleRelationshipInfo

@synthesize parent = _parent;
@synthesize child = _child;
@synthesize card = _card;
@synthesize relationship = _relationship;


- (NSString*)description {
    NSDictionary* meta = @{@"relationship": _relationship,
                           @"card": _card,
                           @"parent": _parent,
                           @"child": _child};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

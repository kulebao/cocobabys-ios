//
//  CBRelationshipInfo.m
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBRelationshipInfo.h"

@implementation CBRelationshipInfo

- (void)setChild:(CBChildInfo *)child {
    if ([child isKindOfClass:[NSDictionary class]]) {
        _child = [CBChildInfo instanceWithDictionary:(NSDictionary*)child];
    }
    else {
        _child = child;
    }
}

- (void)setParent:(CBParentInfo *)parent {
    if ([parent isKindOfClass:[NSDictionary class]]) {
        _parent = [CBParentInfo instanceWithDictionary:(NSDictionary*)parent];
    }
    else {
        _parent = parent;
    }
}

@end

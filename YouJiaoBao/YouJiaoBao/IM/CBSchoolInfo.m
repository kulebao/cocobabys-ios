//
//  CBSchoolInfo.m
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBSchoolInfo.h"
#import "CBSchoolConfigData.h"

@implementation CBSchoolInfo

- (void)setProperties:(NSArray *)properties {
    NSMutableArray* arr = [NSMutableArray array];
    
    for (NSDictionary* obj in properties) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [arr addObject:[CBConfigData instanceWithDictionary:obj]];
        }
        else if ([obj isKindOfClass:[CBConfigData class]]) {
            [arr addObject:obj];
        }
        else {
        }
    }
    _properties = [arr copy];
    
    [self reloadData];
}

- (void)reloadData {
    
}

@end

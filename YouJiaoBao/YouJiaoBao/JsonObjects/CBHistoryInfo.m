//
//  CBHistoryInfo.m
//  YouJiaoBao
//
//  Created by WangXin on 3/8/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBHistoryInfo.h"

@implementation CBHistoryInfo

- (void)setSender:(CBSenderInfo *)sender {
    if ([sender isKindOfClass:[NSDictionary class]]) {
        NSDictionary* senderDict = (NSDictionary*)sender;
        _sender = [CBSenderInfo instanceWithDictionary:senderDict];
    }
    else if ([sender isKindOfClass:[CBSenderInfo class]]) {
        _sender = sender;
    }
    else {
        _sender = nil;
    }
}

- (void)setMedium:(NSArray *)medium {
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:medium.count];
    
    for (NSDictionary* obj in medium) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [list addObject:[CBMediaInfo instanceWithDictionary:obj]];
        }
        else if ([obj isKindOfClass:[CBMediaInfo class]]) {
            [list addObject:obj];
        }
    }
    
    _medium = [list copy];
}

@end

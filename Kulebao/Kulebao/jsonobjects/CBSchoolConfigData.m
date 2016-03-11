//
//  CBSchoolConfigData.m
//  youlebao
//
//  Created by WangXin on 3/11/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBSchoolConfigData.h"

@implementation CBConfigData

@end

@implementation CBSchoolConfigData

- (void)setConfig:(NSArray *)config {
    NSMutableArray* arr = [NSMutableArray array];
    
    for (NSDictionary* obj in config) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [arr addObject:[CBConfigData instanceWithDictionary:obj]];
        }
        else if ([obj isKindOfClass:[CBConfigData class]]) {
            [arr addObject:obj];
        }
        else {
        }
    }
    _config = [arr copy];
    
    [self reloadData];
}

- (void)reloadData {
    for (CBConfigData* conf in _config) {
        if ([conf.name isEqualToString:@"enableHealthRecordManagement"]) {
            _enableHealthRecordManagement = [conf.value isEqualToString:@"true"];
        }
        else if ([conf.name isEqualToString:@"enableFinancialManagement"]) {
            _enableFinancialManagement = [conf.value isEqualToString:@"true"];
        }
        else if ([conf.name isEqualToString:@"enableWarehouseManagement"]) {
            _enableWarehouseManagement = [conf.value isEqualToString:@"true"];
        }
        else if ([conf.name isEqualToString:@"enableDietManagement"]) {
            _enableDietManagement = [conf.value isEqualToString:@"true"];
        }
        else if ([conf.name isEqualToString:@"schoolGroupChat"]) {
            _schoolGroupChat = [conf.value isEqualToString:@"true"];
        }
        else {
            
        }
    }
}

@end

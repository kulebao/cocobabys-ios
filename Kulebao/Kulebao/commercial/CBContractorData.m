//
//  CBContractorData.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBContractorData.h"

@implementation CBContractorData

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_INTEGER(dict, @"id", _uid)
        GET_DICT_INTEGER(dict, @"agent_id", _agent_id)
        GET_DICT_INTEGER(dict, @"contractor_id", _contractor_id)
        GET_DICT_STRING(dict, @"title", _title)
        GET_DICT_STRING(dict, @"address", _address)
        GET_DICT_STRING(dict, @"contact", _contact)
        GET_DICT_STRING(dict, @"time_span", _time_span)
        GET_DICT_STRING(dict, @"detail", _detail)
        GET_DICT_INTEGER(dict, @"updated_at", _updated_at)
        GET_DICT_INTEGER(dict, @"priority", _priority)
        GET_LIST_OBJECT(dict[@"logos"], CBLogoData, _logos)
        _publishing = [CBPublishData instanceWithDictionary:dict[@"publishing"]];
        _price = [CBPriceData instanceWithDictionary:dict[@"price"]];
    }
    return self;
}

@end

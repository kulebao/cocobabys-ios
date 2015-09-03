//
//  CBActivityData.m
//  youlebao
//
//  Created by xin.c.wang on 8/20/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityData.h"

@implementation CBActivityData
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
        _location = [CBLocationData instanceWithDictionary:dict[@"location"]];
    }
    return self;
}

@end

@implementation CBLogoData
- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_STRING(dict, @"url", _url)
    }
    return self;
}

@end

@implementation CBPublishData
- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_INTEGER(dict, @"publish_status", _publish_status)
        GET_DICT_INTEGER(dict, @"published_at", _published_at)
    }
    return self;
}

@end

@implementation CBPriceData
- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_STRING(dict, @"origin", _origin)
        GET_DICT_STRING(dict, @"discounted", _discounted)
    }
    return self;
}

@end

@implementation CBLocationData
- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_FLOAT(dict, @"latitude", _latitude)
        GET_DICT_FLOAT(dict, @"longitude", _longitude)
        GET_DICT_STRING(dict, @"address", _address)
    }
    return self;
}
@end
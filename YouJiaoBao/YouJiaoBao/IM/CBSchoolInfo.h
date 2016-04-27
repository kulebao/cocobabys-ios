//
//  CBSchoolInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBSchoolInfo : CSJsonObject

@property (nonatomic, strong) NSNumber* school_id;
@property (nonatomic, strong) NSNumber* phone;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSString* desc;
@property (nonatomic, strong) NSString* school_logo_url;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSNumber* created_at;
@property (nonatomic, strong) NSString* full_name;
@property (nonatomic, strong) NSArray* properties;

@end

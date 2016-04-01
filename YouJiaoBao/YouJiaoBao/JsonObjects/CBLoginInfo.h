//
//  CBLoginInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"
#import "CBIMInfo.h"

@interface CBLoginInfo : CSJsonObject

@property (nonatomic, strong) NSString* birthday;
@property (nonatomic, strong) NSNumber* created_at;
@property (nonatomic, strong) NSNumber* gender;
@property (nonatomic, strong) NSString* _id;
@property (nonatomic, strong) CBIMInfo* im_token;
@property (nonatomic, strong) NSString* login_name;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, strong) NSString* privilege_group;
@property (nonatomic, strong) NSNumber* school_id;
@property (nonatomic, strong) NSNumber* status;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSString* workduty;
@property (nonatomic, strong) NSString* workgroup;

@end

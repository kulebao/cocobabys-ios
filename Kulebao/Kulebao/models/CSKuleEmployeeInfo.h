//
//  CSKuleEmployeeInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-4-8.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleEmployeeInfo : NSObject

@property (nonatomic, strong) NSString* employeeId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, strong) NSString* workgroup;
@property (nonatomic, strong) NSString* workduty;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, strong) NSString* loginName;
@property (nonatomic, strong) NSString* birthday;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString* privilegeGroup; // privilege_group can be 'operator', 'principal', ''

@end

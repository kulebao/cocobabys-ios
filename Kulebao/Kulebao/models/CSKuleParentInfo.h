//
//  CSKuleParentInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleParentInfo : NSObject
@property (nonatomic, strong) NSString* parentId;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, strong) NSString* birthday;

@end

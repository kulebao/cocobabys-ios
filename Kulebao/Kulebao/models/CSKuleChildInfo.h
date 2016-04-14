//
//  CSKuleChildInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleChildInfo : NSObject <NSCopying>

@property (nonatomic, strong) NSString* childId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* nick;
@property (nonatomic, strong) NSString* birthday;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, assign) NSInteger classId;
@property (nonatomic, strong) NSString* className;


- (NSString *)displayNick;
- (NSString *)displayAge;

@end

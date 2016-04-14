//
//  CSKuleSchoolInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-18.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleSchoolInfo : NSObject

@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* desc;
@property (nonatomic, strong) NSString* schoolLogoUrl;
@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* fullName;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSArray* properties;
@property (nonatomic, strong) NSString* token;

- (BOOL)hasProperty:(NSString*)key;

@end

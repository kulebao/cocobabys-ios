//
//  ModelAccount.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelAccount : NSObject <NSCoding>

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;

+ (id)accountWithUsername:(NSString*)username andPswd:(NSString*)password;

- (BOOL)isValid;

@end

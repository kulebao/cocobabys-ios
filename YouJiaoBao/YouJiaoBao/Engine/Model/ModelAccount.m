//
//  ModelAccount.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-8.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "ModelAccount.h"

@implementation ModelAccount

@synthesize username = _username;
@synthesize password = _password;

+ (id)accountWithUsername:(NSString*)username andPswd:(NSString*)password {
    ModelAccount* account = [ModelAccount new];
    account.username = username;
    account.password = password;
    
    return account;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:(_username ? _username : @"") forKey:@"username"];
    [aCoder encodeObject:(_password ? _password : @"") forKey:@"password"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init])
    {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

- (BOOL)isValid {
    return (_username.length > 0) && (_password.length > 0);
}

@end

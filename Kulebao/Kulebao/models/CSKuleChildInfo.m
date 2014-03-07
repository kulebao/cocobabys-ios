//
//  CSKuleChildInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChildInfo.h"

@implementation CSKuleChildInfo

@synthesize childId = _childId;
@synthesize name = _name;
@synthesize nick = _nick;
@synthesize birthday = _birthday;
@synthesize gender = _gender;
@synthesize portrait = _portrait;
@synthesize classId = _classId;
@synthesize className = _className;

- (id)copyWithZone:(NSZone *)zone {
    CSKuleChildInfo* newChild =  [[[self class] allocWithZone:zone] init];
    
    newChild.childId = self.childId;
    newChild.name = self.name;
    newChild.nick = self.nick;
    newChild.birthday = self.birthday;
    newChild.gender = self.gender;
    newChild.portrait = self.portrait;
    newChild.className = self.className;

    return newChild;
}

- (NSString*)description {
    NSDictionary* meta = @{@"childId": _childId,
                           @"name": _name,
                           @"nick": _nick,
                           @"birthday": _birthday,
                           @"gender": @(_gender),
                           @"portrait": _portrait,
                           @"classId": @(_classId),
                           @"className": _className};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

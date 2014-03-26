//
//  CSKuleAssessInfo.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleAssessInfo.h"

@implementation CSKuleAssessInfo

@synthesize assessId = _assessId;
@synthesize timestamp = _timestamp;
@synthesize publisher = _publisher;
@synthesize comments = _comments;
@synthesize schoolId = _schoolId;
@synthesize childId = _childId;
@synthesize emotion = _emotion;
@synthesize dining = _dining;
@synthesize rest = _rest;
@synthesize activity = _activity;
@synthesize game = _game;
@synthesize exercise = _exercise;
@synthesize selfcare = _selfcare;
@synthesize manner = _manner;

- (NSString*)description {
    NSDictionary* meta = @{@"assessId": @(_assessId),
                           @"timestamp": @(_timestamp),
                           @"publisher": _publisher,
                           @"comments": _comments,
                           @"schoolId": @(_schoolId),
                           @"childId": _childId,
                           @"emotion": @(_emotion),
                           @"dining": @(_dining),
                           @"rest": @(_rest),
                           @"activity": @(_activity),
                           @"game": @(_game),
                           @"exercise": @(_exercise),
                           @"selfcare": @(_selfcare),
                           @"manner": @(_manner)};
    
    NSString* desc = [NSString stringWithFormat:@"%@", meta];
    return desc;
}

@end

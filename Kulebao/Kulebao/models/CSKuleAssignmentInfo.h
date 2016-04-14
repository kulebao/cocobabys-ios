//
//  CSKuleAssignmentInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-12.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleAssignmentInfo : NSObject

@property (nonatomic, assign) NSInteger assignmentId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* publisher;
@property (nonatomic, strong) NSString* iconUrl;
@property (nonatomic, assign) NSInteger classId;

@end

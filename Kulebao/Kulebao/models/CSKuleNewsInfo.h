//
//  CSKuleNewsInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSKuleNewsInfo : NSObject

@property (nonatomic, assign) NSInteger newsId;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger classId;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* image;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) BOOL published;
@property (nonatomic, assign) NSInteger noticeType;

@end

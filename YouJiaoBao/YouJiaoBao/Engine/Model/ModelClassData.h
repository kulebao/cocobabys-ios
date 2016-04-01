//
//  ModelClassData.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSClassHeaderView.h"
#import "CSStudentPickerHeaderView.h"
#import "CBChildInfo.h"
#import "CBClassInfo.h"

@interface ModelBaseData : NSObject
@property (nonatomic, assign) BOOL expand;

- (NSString*)title;
- (NSString*)detail;

@end

@interface ModelClassData : ModelBaseData
@property (nonatomic, strong) CBClassInfo* classInfo;
@property (nonatomic, strong) NSArray* childrenList;
@property (nonatomic, strong) CSClassHeaderView* classHeaderView;

@end

@interface ModelStudentPickerData : ModelBaseData
@property (nonatomic, strong) CBClassInfo* classInfo;
@property (nonatomic, strong) NSArray* childrenList;
@property (nonatomic, strong) CSStudentPickerHeaderView* studentPickerHeaderView;

@end

@interface ModelReaderData : ModelBaseData
@property (nonatomic, strong) CBClassInfo* classInfo;
@property (nonatomic, strong) NSArray* childrenList;
@property (nonatomic, strong) NSMutableSet* childrenReaders;
@property (nonatomic, strong) CSClassHeaderView* classHeaderView;

@end
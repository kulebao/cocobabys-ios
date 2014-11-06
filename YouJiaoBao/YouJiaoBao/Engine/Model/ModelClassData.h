//
//  ModelClassData.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EntityClassInfo.h"
#import "EntityChildInfo.h"
#import "CSClassHeaderView.h"
#import "CSStudentPickerHeaderView.h"

@interface ModelClassData : NSObject

@property (nonatomic, strong) EntityClassInfo* classInfo;
@property (nonatomic, strong) NSArray* childrenList;
@property (nonatomic, strong) CSClassHeaderView* classHeaderView;
@property (nonatomic, strong) CSStudentPickerHeaderView* studentPickerHeaderView;

@property (nonatomic, assign) BOOL expand;

@end

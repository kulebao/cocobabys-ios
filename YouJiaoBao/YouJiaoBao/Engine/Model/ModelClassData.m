//
//  ModelClassData.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "ModelClassData.h"
#import "CBSessionDataModel.h"

@implementation ModelBaseData

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString*)title {
    return @"Title";
}

- (NSString*)detail {
    return @"Detail";
}

@end

@implementation ModelClassData

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString*)title {
    return [NSString stringWithFormat:@"%@", self.classInfo.name];;
}

- (NSString*)detail {
    NSInteger recordNum = 0;
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    for (CBChildInfo* childInfo in self.childrenList) {
        
        CBDailylogInfo* dailyLog = [session getDailylogInfoByChildId:childInfo.child_id];
        if ([dailyLog isToday] && dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckIn) {
            recordNum++;
        }
    }
    
    return [NSString stringWithFormat:@"(实到%ld人/应到%ld人)", recordNum, self.childrenList.count];
}

@end

@implementation ModelStudentPickerData

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString*)title {
    return @"Title";
}

- (NSString*)detail {
    return @"Detail";
}

@end

@implementation ModelReaderData

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString*)title {
    return [NSString stringWithFormat:@"%@", self.classInfo.name];;
}

- (NSString*)detail {
    NSInteger recordNum = 0;
    for (CBChildInfo* childInfo in self.childrenList) {
        if ([self.childrenReaders containsObject:childInfo]) {
            recordNum++;
        }
    }
    
    return [NSString stringWithFormat:@"%ld/%ld", recordNum, self.childrenList.count];
}

@end

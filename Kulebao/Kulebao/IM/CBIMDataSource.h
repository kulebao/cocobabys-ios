//
//  CBIMDataSource.h
//  youlebao
//
//  Created by WangXin on 12/3/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface CBIMDataSource : NSObject <NSCoding, RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource, RCIMReceiveMessageDelegate>

@property (nonatomic, strong, readonly) NSMutableArray* classInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* relationshipInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* teacherInfoList;

+ (instancetype)sharedInstance;

- (void)reloadRelationships;
- (void)reloadTeachers;

@end

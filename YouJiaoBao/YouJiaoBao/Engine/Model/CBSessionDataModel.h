//
//  CBSessionDataModel.h
//  youlebao
//
//  Created by WangXin on 2/17/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import "CBSchoolConfigData.h"
#import "CBRelationshipInfo.h"
#import "CBClassInfo.h"
#import "CBTeacherInfo.h"
#import "CBSchoolInfo.h"
#import "CBDailylogInfo.h"
#import "CBLoginInfo.h"
#import "CBNewsInfo.h"
#import "CBAssessInfo.h"

@interface CBSessionDataModel : NSObject<NSCoding, RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource, RCIMReceiveMessageDelegate>

@property (nonatomic, readonly, strong) NSString* username;
@property (nonatomic, readonly, strong) NSString* tag;

@property (nonatomic, readonly, strong) NSMutableSet* imGroupTags;
@property (nonatomic, strong) CBSchoolConfigData* schoolConfig;
@property (nonatomic, strong) CBLoginInfo* loginInfo;
@property (nonatomic, strong) CBSchoolInfo* schoolInfo;

@property (nonatomic, strong, readonly) NSMutableArray* classInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* relationshipInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* teacherInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* dailylogInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* newsInfoList;
@property (nonatomic, strong, readonly) NSMutableArray* assessInfoList;

@property (nonatomic, strong, readonly) NSArray* childInfoList;
@property (nonatomic, strong, readonly) NSArray* parentInfoList;

@property (nonatomic, strong) NSArray* ineligibleClassList;
@property (nonatomic, readonly) BOOL allowToSendAll;

+ (instancetype)session:(NSString*)username;
+ (instancetype)session:(NSString*)username withTag:(NSString*)tag;
+ (instancetype)thisSession;

- (void)updateSchoolConfig:(NSInteger)schoolId;
- (void)invalidate;
- (void)store;

- (void)updateRelationshipsByJsonObject:(id)jsonObject;
- (void)updateTeacherInfosByJsonObject:(id)jsonObject;
- (void)updateClassInfosByJsonObject:(id)jsonObject;
- (void)updateDailylogsByJsonObject:(id)jsonObject;
- (void)updateChildInfosByJsonObject:(id)jsonObject;
- (NSArray*)updateParentInfosByJsonObject:(id)jsonObject;
- (void)updateNewsInfosByJsonObject:(id)jsonObject;
- (void)reloadNewsInfosByJsonObject:(id)jsonObject;
- (void)updateAssessInfosByJsonObject:(id)jsonObject;

- (CBRelationshipInfo*)getReleationshipById:(NSInteger)rid;
- (CBTeacherInfo*)getTeacherInfoById:(NSInteger)tid;
- (CBClassInfo*)getClassInfoByClassId:(NSInteger)class_id;
- (CBDailylogInfo*)getDailylogInfoByChildId:(NSString*)child_id;
- (CBAssessInfo*)getLatestAssessInfoByChildId:(NSString*)child_id;

- (void)reloadRelationships;
- (void)reloadTeachers;
- (void)reloadSchoolInfo;

@end

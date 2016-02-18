//
//  CSKuleInterpreter.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSKuleRelationshipInfo.h"
#import "CSKuleLoginInfo.h"
#import "CSKuleBindInfo.h"
#import "CSKuleNewsInfo.h"
#import "CSKuleCookbookInfo.h"
#import "CSKuleAssignmentInfo.h"
#import "CSKuleScheduleInfo.h"
#import "CSKuleSchoolInfo.h"
#import "CSKuleCheckInOutLogInfo.h"
#import "CSKuleAssessInfo.h"
#import "CSKuleEmployeeInfo.h"
#import "CSKuleTopicMsg.h"
#import "CSKuleHistoryInfo.h"
#import "CSKuleVideoMember.h"
#import "CSKuleBusLocationInfo.h"

@interface CSKuleInterpreter : NSObject

+ (CSKuleLoginInfo*)decodeLoginInfo:(NSDictionary*)dataJson;

+ (CSKuleBindInfo*)decodeBindInfo:(NSDictionary*)dataJson;

+ (CSKuleRelationshipInfo*)decodeRelationshipInfo:(NSDictionary*)dataJson;

+ (CSKuleChildInfo*)decodeChildInfo:(NSDictionary*)dataJson;

+ (CSKuleParentInfo*)decodeParentInfo:(NSDictionary*)dataJson;

+ (CSKuleNewsInfo*)decodeNewsInfo:(NSDictionary*)dataJson;

+ (CSKuleCookbookInfo*)decodeCookbookInfo:(NSDictionary*)dataJson;

+ (CSKuleRecipeInfo*)decodeRecipeInfo:(NSDictionary*)dataJson;

+ (CSKuleAssignmentInfo*)decodeAssignmentInfo:(NSDictionary*)dataJson;

+ (CSKuleScheduleInfo*)decodeScheduleInfo:(NSDictionary*)dataJson;

+ (CSKuleSchoolInfo*)decodeSchoolInfo:(NSDictionary*)dataJson;

+ (CSKuleCheckInOutLogInfo*)decodeCheckInOutLogInfo:(NSDictionary*)dataJson;

+ (CSKuleTopicMsg*)decodeTopicMsg:(NSDictionary*)dataJson;

+ (CSKuleHistoryInfo*)decodeHistoryInfo:(NSDictionary*)dataJson;

+ (CSKuleAssessInfo*)decodeAssessInfo:(NSDictionary*)dataJson;

+ (CSKuleEmployeeInfo*)decodeEmployeeInfo:(NSDictionary*)dataJson;

+ (CSKuleVideoMember*)decodeVideoMember:(NSDictionary*)dataJson;

+ (CSKuleBusLocationInfo*)decodeBusLocation:(NSDictionary*)dataJson;

@end

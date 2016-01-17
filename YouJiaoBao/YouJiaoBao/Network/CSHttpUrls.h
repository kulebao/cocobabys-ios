//
//  CSHttpUrls.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#ifndef YouJiaoBao_CSHttpUrls_h
#define YouJiaoBao_CSHttpUrls_h

/************************************************************/
/*   七牛存储相关API
 ************************************************************/

// HOST: 七牛上传服务器Host地址
#define kQiniuUploadServerHost      @"http://up.qiniu.com"

// PATH: 获取上传Token
#define kUploadFileTokenPath        @"/ws/fileToken"

// Bucket:
#define kQiniuBucket                @"cocobabys"

// 七牛资源下载服务器Host地址
#define kQiniuDownloadServerHost        kQiniuDownloadHttpsServerHost

#define kQiniuDownloadHttpServerHost    @"http://cocobabys.qiniudn.com"

// 七牛资源下载服务器Host地址 (Https)
#define kQiniuDownloadHttpsServerHost   @"https://dn-cocobabys.qbox.me"

/************************************************************/
/*   Kule API
 ************************************************************/

// HOST: 测试服务服务器接口Host地址
#define kServerHostForTest              @"https://stage2.cocobabys.com"

// HOST: 产品服务服务器接口Host地址
#define kServerHostForProd              @"https://www.cocobabys.com"


#if COCOBABYS_USE_ENV_PROD
    #define kServerHostUsing                kServerHostForProd
#else
    #define kServerHostUsing                kServerHostForTest
#endif

#define kPathEmployeeLogin              @"/employee_login.do"
#define kPathEmployeeManagedClass       @"/kindergarten/%@/employee/%@/class"
#define kPathEmployeeProfile            @"/kindergarten/%@/employee/%@"
#define kPathKindergartenChildList      @"/kindergarten/%@/child"
#define kPathKindergartenRelationship   @"/kindergarten/%@/relationship"
#define kPathKindergartenNewsList       @"/kindergarten/%@/news"
#define kPathKindergartenPostNews       @"/kindergarten/%@/admin/%@/news"
#define kPathKindergartenAssignmentList @"/kindergarten/%@/assignment"
#define kPathChildAssess                @"/kindergarten/%@/child/%@/assess"
#define kPathKindergartenPostNewsV2     @"/api/v2/kindergarten/%@/admin/%@/news"

// PATH: 修改密码
#define kChangePasswordPath             @"/kindergarten/%@/employee/%@/password"

// PATH: 反馈
#define kFeedbackPath                   @"/feedback"

// PATH: History信息
#define kGetHistoryListPath             @"/kindergarten/%@/history/%@/record"

#define kPostBatchHistoryPath           @"/kindergarten/%@/history?child_id=%@"

// PATH: 亲子作业列表
#define kAssignmentListPath             @"/kindergarten/%@/assignment"

// PATH: 在园评价列表
#define kAssessmentListPath             @"/kindergarten/%@/assessments"

// PATH: 当日批量打卡日志
#define kPathKindergartenDailylogList   @"/kindergarten/%@/dailylog"

// PATH: 批量获取新到聊天记录
#define kPathKindergartenSessionList    @"/kindergarten/%@/session"

// PATH: 聊天 - 新接口
#define kTopicPath                      @"/kindergarten/%@/session/%@/record"

// PATH: 指定的聊天记录 - 新接口
#define kTopicIdPath                    @"/kindergarten/%@/session/%@/record/%@"

// PATH: Sender Info
#define kTopicSenderPath                @"/kindergarten/%@/sender/%@"

// PATH: 短信验证
#define kGetSmsCodePath                 @"/ws/verify/phone/%@"
#define kResetPswd                      @"/employee_resetpwd.do"

// PATH: 幼儿园公告列表V2
#define kKindergartenNewsListPathV2     @"/api/v2/kindergarten/%@/news"

// PATH: 幼儿园公告详情V2
#define kKindergartenNewsDetailPathV2   @"/api/v2/kindergarten/%@/news/%@"

// PATH: 幼儿园公告回执V2 /api/v2/kindergarten/:kg/news/:newsId/reader 
#define kKindergartenNewsMarkedPathV2   @"/api/v2/kindergarten/%@/news/%@/reader"

// PATH: 查询幼儿园公告回执状态V2
#define kKindergartenNewsMarkedStatusPathV2     @"/api/v2/kindergarten/%@/news/%@/reader/%@"

// PATH: 查询无资格管理的班级
#define kKindergartenIneligibleClassPathV3      @"/api/v3/kindergarten/%@/employee/%@/ineligible_class"

// PATH: 删除公告
#define kDeleteNewsPath                 @"/kindergarten/%@/admin/%@/news/%@"

#pragma mark - Card Manager
#define kBindCard           @"/kindergarten/%@/relationship/%@"
#define kGetInviteCode      @"/api/v5/invitation_code/%@"
#define kCreateInvitation   @"/api/v5/kindergarten/%@/invitation"

#pragma mark - IM
#define kCBClassesURL           @"/kindergarten/%@/class"
#define kCBTeachersURL          @"/kindergarten/%@/class/%@/manager"
#define kCBEmployeesURL         @"/kindergarten/%@/employee"

// PATH: 获取家庭关系
#define kGetFamilyRelationshipPath  @"/kindergarten/%@/relationship"
#define kGetSchoolInfoPath          @"/kindergarten/%@"

#endif

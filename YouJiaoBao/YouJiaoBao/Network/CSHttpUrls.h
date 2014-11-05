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

#define kServerHostUsing                kServerHostForTest

#define kPathEmployeeLogin              @"/employee_login.do"
#define kPathEmployeeManagedClass       @"/kindergarten/%@/employee/%@/class"
#define kPathEmployeeProfile            @"/kindergarten/%@/employee/%@"
#define kPathKindergartenChildList      @"/kindergarten/%@/child"
#define kPathKindergartenRelationship   @"/kindergarten/%@/relationship"
#define kPathKindergartenNewsList       @"/kindergarten/%@/news"
#define kPathKindergartenPostNews       @"/kindergarten/%@/admin/%@/news"
#define kPathKindergartenAssignmentList @"/kindergarten/%@/assignment"
#define kPathChildAssess                @"/kindergarten/%@/child/%@/assess"

// PATH: 修改密码
#define kChangePasswordPath             @"/kindergarten/%@/employee/%@/password"

// PATH: 反馈
#define kFeedbackPath                   @"/feedback"

// PATH: History信息
#define kGetHistoryListPath             @"/kindergarten/%@/history/%@/record"

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

#endif

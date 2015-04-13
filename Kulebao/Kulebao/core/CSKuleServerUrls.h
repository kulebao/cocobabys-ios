//
//  CSKuleServerUrls.h
//  Kulebao
//
//  Created by xin.c.wang on 14-2-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#ifndef Kulebao_CSKuleServerUrls_h
#define Kulebao_CSKuleServerUrls_h


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
#define kServerHostForTest          @"https://stage.cocobabys.com"

// HOST: 产品服务服务器接口Host地址
#define kServerHostForProd          @"https://www.cocobabys.com"

//// HOST: 服务器接口Host地址
//#ifdef DEBUG
//    #define kServerHost                 kServerHostForTest
//#else
//    #define kServerHost                 kServerHostForProd
//#endif

// PATH: 检查电话号码
#define kCheckPhoneNumPath          @"/checkphonenum.do"

// PATH: 登录
#define kLoginPath                  @"/login.do"

// PATH: 获取绑定信息
#define kReceiveBindInfoPath        @"/api/v1/binding" //@"/receiveBindInfo.do"

// PATH: 修改密码
#define kChangePasswordPath         @"/changepwd.do"

// PATH: 检查电话号码
#define kCheckRegAuthCodePath       @"/check_reg_authcode.do"

// PATH: 获取家庭关系
#define kGetFamilyRelationshipPath  @"/kindergarten/%@/relationship"

// PATH: 小孩信息
#define kChildInfoPath              @"/kindergarten/%@/child/%@"

// PATH: 幼儿园公告列表
#define kKindergartenNewsListPath   @"/kindergarten/%@/news"

// PATH: 食谱
#define kKindergartenCookbooksPath  @"/kindergarten/%@/cookbook"

// PATH: 亲子作业列表
#define kAssignmentListPath         @"/kindergarten/%@/assignment"

// PATH: 课程表
#define kSchedulesPath              @"/kindergarten/%@/class/%@/schedule"

// PATH: 学校介绍
#define kGetSchoolInfoPath          @"/kindergarten/%@/detail"

// PATH: 签到签出记录
#define kGetCheckInOutLogPath       @"/kindergarten/%@/child/%@/dailylog"

// PATH: 聊天 - 旧接口
#define kChatingPath                @"/kindergarten/%@/conversation/%@"

// PATH: 聊天 - 新接口
#define kTopicPath                  @"/kindergarten/%@/session/%@/record"

// PATH: 指定的聊天记录 - 新接口
#define kTopicIdPath                @"/kindergarten/%@/session/%@/record/%@"

// PATH: 园内评价
#define kAssessPath                 @"/kindergarten/%@/child/%@/assess"

// PATH: 短信验证
#define kGetSmsCodePath             @"/ws/verify/phone/%@"

// PATH: 重置密码
#define kResetPswdPath              @"/resetpwd.do"

// PATH: 反馈
#define kFeedbackPath               @"/feedback"

// PATH: 雇员信息
#define kGetEmployeeInfoPath        @"/kindergarten/%@/employee"

// PATH: Sender信息
#define kGetSenderInfoPath          @"/kindergarten/%@/sender/%@"

// PATH: History信息
#define kGetHistoryListPath         @"/kindergarten/%@/history/%@/record"

// PATH: 删除History信息
#define kDeleteHistoryListPath      @"/kindergarten/%@/history/%@/record/%@"

// PATH: 获取视频账号列表
#define kGetVideoMemberListPath     @"/api/v1/kindergarten/%@/video_member"

// PATH: 获取视频账号
#define kGetVideoMemberPath         @"/api/v1/kindergarten/%@/video_member/%@"

// PATH: 获取公用视频账号
#define kGetDefaultVideoMemberPath  @"/api/v1/kindergarten/%@/video_member/default"

// PATH: 获取学校配置
#define kGetKindergartenConfigurePath  @"/api/v2/school_config/%@"

// PATH: 幼儿园公告列表V2
#define kKindergartenNewsListPathV2     @"/api/v2/kindergarten/%@/news"

// PATH: 幼儿园公告详情V2
#define kKindergartenNewsDetailPathV2   @"/api/v2/kindergarten/%@/news/%@"

// PATH: 幼儿园公告回执V2
#define kKindergartenNewsMarkedPathV2   @"/api/v2/kindergarten/%@/news/%@/reader"

// PATH: 查询幼儿园公告回执状态V2
#define kKindergartenNewsMarkedStatusPathV2   @"/api/v2/kindergarten/%@/news/%@/reader/%@"

#endif
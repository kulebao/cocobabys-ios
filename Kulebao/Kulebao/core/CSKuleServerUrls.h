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
#define kQiniuDownloadServerHost    @"http://cocobabys.qiniudn.com"


/************************************************************/
/*   Kule API
 ************************************************************/

// HOST: 服务器接口Host地址
#define kServerHost                 @"https://www.cocobabys.com"

// PATH: 检查电话号码
#define kCheckPhoneNumPath          @"/checkphonenum.do"

// PATH: 登录
#define kLoginPath                  @"/login.do"

// PATH: 获取绑定信息
#define kReceiveBindInfoPath        @"/receiveBindInfo.do"

// PATH: 检查电话号码
#define kCheckRegAuthCodePath       @"/check_reg_authcode.do"

// PATH: 获取家庭关系
#define kGetFamilyRelationshipPath  @"/kindergarten/%@/relationship"

// PATH: 小孩信息
#define kChildInfoPath              @"/kindergarten/%@/child/%@"

// PATH: 幼儿园公告
#define kKindergartenNewsListPath   @"/kindergarten/%@/news"

// PATH: 食谱
#define kKindergartenCookbooksPath  @"/kindergarten/%@/cookbook"

// PATH: 亲子作业列表
#define kAssignmentListPath         @"/kindergarten/%@/assignment"

// PATH: 课程表
#define kSchedulesPath              @"/kindergarten/%@/class/%@/schedule"

// PATH: 学校介绍
#define kGetSchoolInfoPath          @"/kindergarten/%@"

// PATH: 签到签出记录
#define kGetCheckInOutLogPath       @"/kindergarten/%@/child/%@/dailylog"

#endif
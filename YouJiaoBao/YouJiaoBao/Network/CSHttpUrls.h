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
#define kPathKindergartenChildList      @"/kindergarten/%@/child"
#define kPathKindergartenDailylogList   @"/kindergarten/%@/dailylog"
#define kPathKindergartenRelationship   @"/kindergarten/%@/relationship"
#define kPathKindergartenNewsList       @"/kindergarten/%@/news"
#define kPathKindergartenAssignmentList @"/kindergarten/%@/assignment"

// PATH: 修改密码
#define kChangePasswordPath             @"/kindergarten/%@/employee/%@/password"

// PATH: 反馈
#define kFeedbackPath               @"/feedback"

// PATH: History信息
#define kGetHistoryListPath         @"/kindergarten/%@/history/%@/record"

#endif

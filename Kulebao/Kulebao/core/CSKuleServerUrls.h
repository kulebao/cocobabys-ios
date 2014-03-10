//
//  CSKuleServerUrls.h
//  Kulebao
//
//  Created by xin.c.wang on 14-2-26.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#ifndef Kulebao_CSKuleServerUrls_h
#define Kulebao_CSKuleServerUrls_h


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
#define kGetFamilyRelationship      @"/kindergarten/%@/relationship"

// PATH: 小孩信息
#define kChildInfoPath              @"/kindergarten/%@/child/%@"

// PATH: 幼儿园公告
#define kKindergartenNewsListPath   @"/kindergarten/%@/news"

#endif
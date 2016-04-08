// CSFirImApi.h
//
// Copyright (c) 2014-2015 Xinus Wang. All rights reserved.
// https://github.com/xinus/CSKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "CSJsonEntityData.h"

/*
 This is api for services of FIR.im website
 ref: http://fir.im/docs
 */

#define API_FIRIM_HOST        @"http://api.fir.im"
#define API_FIRIM_TIMEOUT     60

@class FirImAppInfoData;
@interface CSFirImApi : NSObject

+ (void)getLatestAppInfo:(NSString*)appId
                apiToken:(NSString*)apiToken
                complete:(void (^)(FirImAppInfoData* appInfoData, NSError* error))block;

@end

/*
 {"name":"youlebao","version":"150822","changelog":"新增商户模块；\r\n修复成长经历发布视频时会上传上次发布的照片的问题，处理同时包含视频和照片的成长经历时，过滤掉视频；\r\n优化性能，对发布的图片直接缓存；\r\n修改分享标题；\r\n修复校车位置不移动的问题；","updated_at":1440243334,"versionShort":"2.3.0","build":"150822","installUrl":"https://download.fir.im/v2/app/install/540b29930a99448660000086?download_token=7b52fe853dfe4376d70e8973a4fec57b","install_url":"https://download.fir.im/v2/app/install/540b29930a99448660000086?download_token=7b52fe853dfe4376d70e8973a4fec57b","update_url":"http://fir.im/ylbao","binary":{"fsize":27368487}}
 */
@class FirImAppBinaryInfoData;
@interface FirImAppInfoData : CSJsonEntityData
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* changelog;
@property (nonatomic, assign) NSInteger updated_at;
@property (nonatomic, strong) NSString* versionShort;
@property (nonatomic, strong) NSString* build;
@property (nonatomic, strong) NSString* installUrl;
@property (nonatomic, strong) NSString* install_url;
@property (nonatomic, strong) NSString* update_url;
@property (nonatomic, strong) FirImAppBinaryInfoData* binary;
@end

@interface FirImAppBinaryInfoData : CSJsonEntityData
@property (nonatomic, assign) NSInteger fsize;
@end

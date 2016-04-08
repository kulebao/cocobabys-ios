// CSFirImApi.h
//
// Copyright (c) 2014-2016 Xinus Wang. All rights reserved.
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

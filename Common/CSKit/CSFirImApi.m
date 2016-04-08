// CSFirImApi.m
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
#import "CSFirImApi.h"

@implementation CSFirImApi

+ (void)getLatestAppInfo:(NSString*)appId
                apiToken:(NSString*)apiToken
                complete:(void (^)(FirImAppInfoData* appData, NSError* error))block {
    NSString* reqUrl = [NSString stringWithFormat:@"/apps/latest/%@?api_token=%@",
                        appId,
                        apiToken];
    
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:reqUrl relativeToURL:[NSURL URLWithString:API_FIRIM_HOST]]];
    req.HTTPMethod = @"GET";
    req.timeoutInterval = API_FIRIM_TIMEOUT;
    
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSError* error = connectionError;
                               FirImAppInfoData* appInfoData = nil;
                               if (error == nil) {
                                   NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:NSJSONReadingMutableLeaves
                                                                                              error:&error];
                                   if (error == nil) {
                                       appInfoData = [FirImAppInfoData instanceWithDictionary:jsonDict];
                                   }
                               }
                               
                               if (block) {
                                   block(appInfoData, error);
                               }
                           }];
}

@end

@implementation FirImAppInfoData
- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_STRING(dict, @"name", _name)
        GET_DICT_STRING(dict, @"version", _version)
        GET_DICT_STRING(dict, @"changelog", _changelog)
        GET_DICT_INTEGER(dict, @"updated_at", _updated_at)
        GET_DICT_STRING(dict, @"versionShort", _versionShort)
        GET_DICT_STRING(dict, @"build", _build)
        GET_DICT_STRING(dict, @"installUrl", _installUrl)
        GET_DICT_STRING(dict, @"install_url", _install_url)
        GET_DICT_STRING(dict, @"update_url", _update_url)
        _binary = [FirImAppBinaryInfoData instanceWithDictionary:dict[@"binary"]];
    }
    return self;
}

@end

@implementation FirImAppBinaryInfoData
- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super initWithDictionary:dict]) {
        GET_DICT_INTEGER(dict, @"fsize", _fsize)
    }
    return self;
}

@end
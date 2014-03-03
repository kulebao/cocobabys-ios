//
//  CSHttpClient.h
//  CSKit
//
//  Created by xin.c.wang on 13-4-18.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFJSONRequestOperation+CSExtends.h"

#define kServerHost         @"https://www.cocobabys.com"
#define kCheckPhoneNumUrl   @"/checkphonenum.do"

@interface CSHttpClient : AFHTTPClient

+ (id)httpClient;

- (void)httpRequestWithMethod:(NSString *)method
                         path:(NSString *)path
                   parameters:(NSDictionary *)parameters
                      success:(SuccessResponseHandler)success
                      failure:(FailureResponseHandler)failure;

@end

//
//  CSHttpClient.h
//  CSKit
//
//  Created by xin.c.wang on 13-4-18.
//  Copyright (c) 2013年 CSKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFJSONRequestOperation+CSKit.h"

@interface CSHttpClient : AFHTTPClient

+ (id)httpClientWithHost:(NSURL*)hostUrl;

- (AFHTTPRequestOperation*)httpRequestWithMethod:(NSString *)method
                         path:(NSString *)path
                   parameters:(NSDictionary *)parameters
                      success:(SuccessResponseHandler)success
                      failure:(FailureResponseHandler)failure;

@end
//
//  AFJSONRequestOperation+CSKit.h
//  CSKit
//
//  Created by xin.c.wang on 13-4-23.
//  Copyright (c) 2013年 CSKit. All rights reserved.
//

#import "AFJSONRequestOperation.h"

typedef void (^SuccessResponseHandler) (AFHTTPRequestOperation *operation, id dataJson);
typedef void (^FailureResponseHandler) (AFHTTPRequestOperation *operation, NSError *error);

@interface AFJSONRequestOperation (CSKit)

+ (instancetype)CSJSONRequestOperationWithRequest:(NSMutableURLRequest *)urlRequest
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

@end

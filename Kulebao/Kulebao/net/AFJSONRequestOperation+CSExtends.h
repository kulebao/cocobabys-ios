//
//  AFJSONRequestOperation+CSExtends.h
//  CSKit
//
//  Created by xin.c.wang on 13-4-23.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "NSDictionary+CSExtends.h"

typedef void (^SuccessResponseHandler) (NSURLRequest *request,id dataJson);
typedef void (^FailureResponseHandler) (NSURLRequest *request, NSError *error);

@interface AFJSONRequestOperation (CSExtends)

+ (instancetype)CSJSONRequestOperationWithRequest:(NSMutableURLRequest *)urlRequest
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

@end

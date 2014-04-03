//
//  AFJSONRequestOperation+CSKit.m
//  CSKit
//
//  Created by xin.c.wang on 13-4-23.
//  Copyright (c) 2013年 CSKit. All rights reserved.
//

#import "AFJSONRequestOperation+CSKit.h"
#import "CSAppDelegate.h"

@implementation AFJSONRequestOperation (CSKit)

+ (instancetype)CSJSONRequestOperationWithRequest:(NSMutableURLRequest *)urlRequest
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure {
        
    AFJSONRequestOperation *requestOperation = [(AFJSONRequestOperation *)[self alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && success) {
            success(operation, responseObject);
        }
        else if(failure) {
            NSError* error = [NSError errorWithDomain:@"CSKit"
                                                 code:-9999
                                             userInfo: @{NSLocalizedDescriptionKey:@"服务异常"}];
            failure(operation, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.response.statusCode == 401) {
            [gApp.engine retryRequestOperationAfterBind:operation];
        }
        else if (failure) {
            failure(operation, error);
        }
    }];
    
    return requestOperation;
}
@end

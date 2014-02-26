//
//  AFJSONRequestOperation+CSExtends.m
//  CSKit
//
//  Created by xin.c.wang on 13-4-23.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import "AFJSONRequestOperation+CSExtends.h"
#import "CSAppDelegate.h"

@implementation AFJSONRequestOperation (CSExtends)

+ (instancetype)CSJSONRequestOperationWithRequest:(NSMutableURLRequest *)urlRequest
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure {
        
    AFJSONRequestOperation *requestOperation = [(AFJSONRequestOperation *)[self alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && success) {
            success(operation.request, responseObject);
        }
        else if(failure) {
            NSError* error = [NSError errorWithDomain:@"CSKit"
                                                 code:-9999
                                             userInfo:[NSDictionary dictionaryWithObject:@"服务异常" forKey:NSLocalizedDescriptionKey]];
            failure(operation.request, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, error);
        }
    }];
    
    return requestOperation;
}
@end

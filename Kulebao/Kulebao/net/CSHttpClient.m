//
//  CSHttpClient.m
//  CSKit
//
//  Created by xin.c.wang on 13-4-18.
//  Copyright (c) 2013年 Codingsoft. All rights reserved.
//

#import "CSHttpClient.h"
#import "AFNetworkActivityIndicatorManager.h"
@interface CSHttpClient ()

@end

@implementation CSHttpClient

- (id)init {
    if (self = [super init]) {
        self.operationQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

+ (id)httpClient {
    NSURL* baseUrl = [NSURL URLWithString:kServerHost];
    
    CSHttpClient* client = [[CSHttpClient alloc] initWithBaseURL:baseUrl];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        CSLog(@"ReachabilityStatusChangeBlock:%d", status);
    }];
    
    return client;
}

- (void)httpRequestWithMethod:(NSString *)method
                         path:(NSString *)path
                   parameters:(NSDictionary *)parameters
                      success:(SuccessResponseHandler)success
                      failure:(FailureResponseHandler)failure {
    
    NSMutableURLRequest* req = [self requestWithMethod:method
                                                  path:path
                                            parameters:parameters];
    req.timeoutInterval = 30;
    
    AFJSONRequestOperation* jsonOperation =
    [AFJSONRequestOperation CSJSONRequestOperationWithRequest:req
                                                      success:success
                                                      failure:failure];
    
    [self enqueueHTTPRequestOperation:jsonOperation];
}

@end

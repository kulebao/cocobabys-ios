//
//  CSHttpClient.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSHttpClient.h"
#import "CSHttpUrls.h"

@interface CSHttpClient ()

@property (nonatomic, strong) AFHTTPRequestOperationManager* opManager;

@end

@implementation CSHttpClient
@synthesize opManager = _opManager;

+ (id)sharedInstance {
    static CSHttpClient* s_httpClient = nil;
    if (s_httpClient == nil) {
        s_httpClient = [CSHttpClient new];
    }
    
    return s_httpClient;
}

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (AFHTTPRequestOperationManager*)opManager {
    if (_opManager == nil) {
        _opManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kServerHostForTest]];
        
        _opManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opManager.responseSerializer = responseSerializer;
        
        _opManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return _opManager;
}

- (AFHTTPRequestOperation*)opLoginWithUsername:(NSString*)username
                                      password:(NSString*)password {
    NSParameterAssert(username && password);

    id parameters = @{@"account_name": username,
                      @"password" : password};
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
    };
    
    AFHTTPRequestOperation* op =[self.opManager POST:kPathEmployeeLogin
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    
    return op;
}

@end

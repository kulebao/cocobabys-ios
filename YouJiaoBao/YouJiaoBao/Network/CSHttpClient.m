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
        [_opManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"source"];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opManager.responseSerializer = responseSerializer;
        
        _opManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return _opManager;
}

- (AFHTTPRequestOperation*)opLoginWithUsername:(NSString*)username
                                      password:(NSString*)password
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure {
    NSParameterAssert(username && password);

    id parameters = @{@"account_name": username,
                      @"password" : password};

    AFHTTPRequestOperation* op =[self.opManager POST:kPathEmployeeLogin
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    
    return op;
}

- (AFHTTPRequestOperation*)opGetClassListOfKindergarten:(NSInteger)schoolId
                                         withEmployeeId:(NSString*)employeePhone
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure {
    NSParameterAssert(employeePhone);
    
    id parameters = @{@"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathEmployeeManagedClass, @(schoolId), employeePhone];
    
    AFHTTPRequestOperation* op =[self.opManager GET:apiUrl
                                         parameters:parameters
                                            success:success
                                            failure:failure];
    
    return op;
}

- (AFHTTPRequestOperation*)opGetChildListOfKindergarten:(NSInteger)schoolId
                                          withClassList:(NSArray*)classIdList
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure {
    id parameters = @{@"class_id": [classIdList componentsJoinedByString:@","],
                      @"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenChildList, @(schoolId)];
    
    AFHTTPRequestOperation* op =[self.opManager GET:apiUrl
                                         parameters:parameters
                                            success:success
                                            failure:failure];
    return op;
    
}

- (AFHTTPRequestOperation*)opGetDailylogOfKindergarten:(NSInteger)schoolId
                                         withClassList:(NSArray*)classIdList
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure {
    id parameters = @{@"class_id": [classIdList componentsJoinedByString:@","],
                      @"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenDailylogList, @(schoolId)];
    
    AFHTTPRequestOperation* op =[self.opManager GET:apiUrl
                                         parameters:parameters
                                            success:success
                                            failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opGetRelationshipOfChild:(NSString*)childId
                                     inKindergarten:(NSInteger)schoolId
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    id parameters = @{@"child": childId};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenRelationship, @(schoolId)];
    
    AFHTTPRequestOperation* op =[self.opManager GET:apiUrl
                                         parameters:parameters
                                            success:success
                                            failure:failure];
    return op;
    
}

- (AFHTTPRequestOperation*)opGetNewsOfClasses:(NSArray*)classIdList
                               inKindergarten:(NSInteger)schoolId
                                         from:(NSNumber*)from
                                           to:(NSNumber*)to
                                         most:(NSNumber*)most
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (classIdList.count > 0) {
        [parameters setObject:[classIdList componentsJoinedByString:@","] forKey:@"class_id"];
    }
    
    if (from) {
        [parameters setObject:from forKey:@"from"];
    }
    
    if (to) {
        [parameters setObject:to forKey:@"to"];
    }
    
    if (most) {
        [parameters setObject:most forKey:@"most"];
    }
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenNewsList, @(schoolId)];
    
    AFHTTPRequestOperation* op =[self.opManager GET:apiUrl
                                         parameters:parameters
                                            success:success
                                            failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opGetAssignmentsOfClasses:(NSArray*)classIdList
                                      inKindergarten:(NSInteger)schoolId
                                                from:(NSNumber*)from
                                                  to:(NSNumber*)to
                                                most:(NSNumber*)most
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (classIdList.count > 0) {
        [parameters setObject:[classIdList componentsJoinedByString:@","] forKey:@"class_id"];
    }
    
    if (from) {
        [parameters setObject:from forKey:@"from"];
    }
    
    if (to) {
        [parameters setObject:to forKey:@"to"];
    }
    
    if (most) {
        [parameters setObject:most forKey:@"most"];
    }
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenAssignmentList, @(schoolId)];
    
    AFHTTPRequestOperation* op = [self.opManager GET:apiUrl
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    return op;
    
}

- (AFHTTPRequestOperation*)opChangePassword:(NSString*)newPswd
                                withOldPswd:(NSString*)oldPswd
                                 forAccount:(EntityLoginInfo*)loginInfo
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure {
    NSParameterAssert(newPswd);
    NSParameterAssert(oldPswd);
    NSParameterAssert(loginInfo);
    
    NSString* apiUrl = [NSString stringWithFormat:kChangePasswordPath, loginInfo.schoolId, loginInfo.phone];
    
    NSDictionary* parameters = @{@"employee_id": loginInfo.uid,
                                 @"school_id" : loginInfo.schoolId,
                                 @"phone" : loginInfo.phone,
                                 @"login_name" : loginInfo.loginName,
                                 @"old_password": oldPswd,
                                 @"new_password": newPswd};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opSendFeedback:(NSString*)account
                              withContent:(NSString*)msgContent
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure {
    NSParameterAssert(account);
    NSParameterAssert(msgContent);
    
    NSString* apiUrl = kFeedbackPath;
    
    NSDictionary* parameters = @{@"phone": account,
                                 @"content": msgContent,
                                 @"source": @"ios_teacher"};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

@end

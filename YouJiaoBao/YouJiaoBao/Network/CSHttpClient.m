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
@property (nonatomic, strong) AFHTTPRequestOperationManager* opQiniuManager;

@end

@implementation CSHttpClient
@synthesize opManager = _opManager;
@synthesize opQiniuManager = _opQiniuManager;

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
        _opManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kServerHostUsing]];
        
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

- (AFHTTPRequestOperationManager*)opQiniuManager {
    if (_opQiniuManager == nil) {
        _opQiniuManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kQiniuUploadServerHost]];
        
        _opQiniuManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
//        [_opQiniuManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"source"];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opQiniuManager.responseSerializer = responseSerializer;
        
        _opQiniuManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return _opQiniuManager;
}

- (AFHTTPRequestOperation*)opUploadToQiniu:(NSData*)data
                                   withKey:(NSString*)key
                                  withMime:(NSString*)mime
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    
    id _success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* token = [responseObject valueForKeyNotNull:@"token"];
        if (token) {
            [self _opDoUploadToQiniuWithData:data
                                   withToken:token
                                      andKey:key
                                     andMime:mime
                                     success:success
                                     failure:failure];
        }
        else {
            NSError* error = [NSError errorWithDomain:@"Qiniu"
                                                 code:-8888
                                             userInfo: @{NSLocalizedDescriptionKey:@"Invalid Token."}];
            
            failure(operation, error);
        }
    };
    
    id _failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    };
    

    AFHTTPRequestOperation* op = [self _opGetUploadTokenWithKey:key
                                                        success:_success
                                                        failure:_failure];
    
    return op;
}

- (AFHTTPRequestOperation*)_opGetUploadTokenWithKey:(NSString*)key
                         success:(SuccessResponseHandler)success
                         failure:(FailureResponseHandler)failure {
    NSParameterAssert(key);
    
    NSString* path = kUploadFileTokenPath;
    
    NSDictionary* parameters = @{@"bucket": kQiniuBucket,
                                 @"key": key};
    
    AFHTTPRequestOperation* op =[self.opManager GET:path
                                         parameters:parameters
                                            success:success
                                            failure:failure];
    
    return op;
}

- (AFHTTPRequestOperation*)_opDoUploadToQiniuWithData:(NSData*)data
                                           withToken:(NSString*)token
                                              andKey:(NSString*)key
                                             andMime:(NSString*)mime
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure {
    
    id _formDataBlock = ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:key
                                mimeType:mime];
        
        [formData appendPartWithFormData:[key dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"key"];
        
        [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"token"];
    };
    
    AFHTTPRequestOperation* op =[self.opQiniuManager POST:@"/"
                                               parameters:nil
                                constructingBodyWithBlock:_formDataBlock
                                                  success:success
                                                  failure:failure];
    return op;
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


- (AFHTTPRequestOperation*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
                                          withSenderId:(NSString*)senderId
                                           withChildId:(NSString*)childId
                                           withContent:(NSString*)content
                                      withImageUrlList:(NSArray*)imgUrlList
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure {
    NSString* apiUrl = [NSString stringWithFormat:kGetHistoryListPath, @(kindergarten), childId];
    
    id msgSender = @{@"id": senderId, @"type": @"t"};
    
    NSMutableArray* mediumList = [NSMutableArray array];
    for (NSString* urlString in imgUrlList) {
        [mediumList addObject:@{@"url": urlString, @"type": @"image"}];
    }
    
    NSDictionary* parameters = @{@"topic": childId,
                                 @"content": content ? content : @"",
                                 @"medium" : mediumList,
                                 @"sender": msgSender};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opPostNewsOfKindergarten:(NSInteger)kindergarten
                                         withSender:(EntityLoginInfo*)senderInfo
                                        withClassId:(NSNumber*)classId
                                        withContent:(NSString*)content
                                          withTitle:(NSString*)title
                                   withImageUrlList:(NSArray*)imgUrlList
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenPostNews, @(kindergarten), senderInfo.uid];
    
    NSString* imgUrl = [imgUrlList firstObject];
    
    NSDictionary* parameters = @{@"school_id" : @(kindergarten),
                                 @"content": content ? content : @"",
                                 @"title": title ? title : @"",
                                 @"published" : @"true",
                                 @"class_id" : classId,
                                 @"publisher_id": senderInfo.uid,
                                 @"image" : imgUrl ? imgUrl : @""};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opPostAssignmentOfKindergarten:(NSInteger)kindergarten
                                               withSender:(EntityLoginInfo*)senderInfo
                                              withClassId:(NSNumber*)classId
                                              withContent:(NSString*)content
                                                withTitle:(NSString*)title
                                         withImageUrlList:(NSArray*)imgUrlList
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    NSString* apiUrl = [NSString stringWithFormat:kAssignmentListPath, @(kindergarten)];
    
    NSString* imgUrl = [imgUrlList firstObject];
    
    NSDictionary* parameters = @{@"content": content ? content : @"",
                                 @"title": title ? title : @"",
                                 @"class_id" : classId,
                                 @"publisher": senderInfo.name,
                                 @"publisher_id" : senderInfo.uid,
                                 @"icon_url" : imgUrl ? imgUrl : @""};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}
@end

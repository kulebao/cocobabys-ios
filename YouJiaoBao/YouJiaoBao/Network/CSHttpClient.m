//
//  CSHttpClient.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSHttpClient.h"
#import "CSHttpUrls.h"
#import "ModelAssessment.h"

@interface CSHttpClient ()

@property (nonatomic, strong) AFHTTPRequestOperationManager* opManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager* opQiniuManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager* opiTunesManager;

@end

@implementation CSHttpClient
@synthesize opManager = _opManager;
@synthesize opQiniuManager = _opQiniuManager;
@synthesize opiTunesManager = _opiTunesManager;

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

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path {
    NSURL* url = nil;
    if (path.length > 0) {
        if ([path hasPrefix:@"http"]) {
            url = [NSURL URLWithString:path];
        }
        else {
            url = [NSURL URLWithString:path
                         relativeToURL:[NSURL URLWithString:kServerHostUsing]];
        }
    }
    
    return url;
}

#pragma mark - Operations
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
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opQiniuManager.responseSerializer = responseSerializer;
        
        _opQiniuManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return _opQiniuManager;
}

- (AFHTTPRequestOperationManager*)opiTunesManager {
    if (_opiTunesManager == nil) {
        _opiTunesManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kQiniuUploadServerHost]];
        
        _opiTunesManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opiTunesManager.responseSerializer = responseSerializer;
        
        _opiTunesManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return _opiTunesManager;
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

- (AFHTTPRequestOperation*)opGetDailyLogListOfKindergarten:(NSInteger)schoolId
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

- (AFHTTPRequestOperation*)opGetSessionListOfKindergarten:(NSInteger)schoolId
                                            withClassList:(NSArray*)classIdList
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    id parameters = @{@"class_id": [classIdList componentsJoinedByString:@","],
                      @"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenSessionList, @(schoolId)];
    
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

- (AFHTTPRequestOperation*)opCheckUpdates:(NSString*)appId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure {
    NSString* apiUrl = @"/lookup";
    NSDictionary* parameters = @{@"id": appId};
    
    AFHTTPRequestOperation* op = [self.opiTunesManager POST:apiUrl
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opGetTopicMsgsOfChild:(NSString*)childId
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(long long)fromId
                                              to:(long long)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure {
    NSParameterAssert(childId);
    
    NSString* apiUrl = [NSString stringWithFormat:kTopicPath, @(kindergarten), childId];
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    AFHTTPRequestOperation* op = [self.opManager GET:apiUrl
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opDeleteTopicMsgs:(long long)msgId
                                     ofChild:(NSString*)childId
                              inKindergarten:(NSInteger)kindergarten
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(childId);
    
    NSString* apiUrl = [NSString stringWithFormat:kTopicIdPath, @(kindergarten), childId, @(msgId)];
    
    NSMutableDictionary* parameters = nil;
    
    AFHTTPRequestOperation* op = [self.opManager DELETE:apiUrl
                                             parameters:parameters
                                                success:success
                                                failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opSendTopicMsg:(NSString*)msgBody
                               withSender:(EntityLoginInfo*)senderInfo
                             withMediaUrl:(NSString*)mediaUrl
                              ofMediaType:(NSString*)mediaType
                                  ofChild:(NSString*)childId
                           inKindergarten:(NSInteger)kindergarten
                             retrieveFrom:(long long)fromId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure {
    NSParameterAssert(msgBody || mediaUrl); // 不能同时为空
    NSParameterAssert(childId);
    
    
    NSString* apiUrl = [NSString stringWithFormat:kTopicPath, @(kindergarten), childId];
    
    if (fromId >= 0) {
        apiUrl = [apiUrl stringByAppendingFormat:@"?retrieve_recent_from=%lld", fromId];
    }
    
    /*
     {"topic":"1_1396844597394",
     "content":"我再说两句",
     "media":{"url":"http://suoqin-test.u.qiniudn.com/FgPmIcRG6BGocpV1B9QMCaaBQ9LK","type":"image"},
     "sender":{"id":"2_1003_1396844438388","type":"p"}}
     */
    
    long long timestamp = [[NSDate date] timeIntervalSince1970]*1000;
    
    id msgMedia = @{@"url": @"",
                    @"type": @""};
    
    if (mediaUrl.length > 0) {
        msgMedia = @{@"url": [[self urlFromPath:mediaUrl] absoluteString],
                     @"type": mediaType};
    }
    
    id msgSender = @{@"id": senderInfo.uid,
                     @"type": @"t"};
    
    NSDictionary* parameters = @{@"topic": childId,
                                 @"timestamp": @(timestamp),
                                 @"content": msgBody ? msgBody : @"",
                                 @"media": msgMedia,
                                 @"sender": msgSender};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opGetTopicMsgSender:(NSString*)senderId
                                        ofType:(NSString*)senderType
                                inKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure {
    NSParameterAssert(senderId && senderType);
    
    NSString* apiUrl = [NSString stringWithFormat:kTopicSenderPath, @(kindergarten), senderId];
    
    NSDictionary* parameters = @{@"type": senderType};
    
    AFHTTPRequestOperation* op = [self.opManager GET:apiUrl
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opSendAssessment:(NSArray*)assessmentList
                             inKindergarten:(NSInteger)kindergarten
                                 fromSender:(NSString*)sender
                               withSenderId:(NSString*)senderId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure {
    NSString* apiUrl = [NSString stringWithFormat:kAssessmentListPath, @(kindergarten)];
    
    NSMutableArray* payload = [NSMutableArray array];
    for (ModelAssessment* assessment in assessmentList) {
        NSDictionary* dict = @{@"publisher": sender,
                               @"publisher_id": senderId,
                               @"comments": assessment.comments,
                               @"emotion": @(assessment.emotion),
                               @"dining": @(assessment.dining),
                               @"rest": @(assessment.rest),
                               @"activity": @(assessment.activity),
                               @"game": @(assessment.game),
                               @"exercise": @(assessment.exercise),
                               @"self_care": @(assessment.selfCare),
                               @"manner": @(assessment.manner),
                               @"child_id": assessment.childId,
                               @"school_id":@(kindergarten)
                               };
        [payload addObject:dict];
    }
    
    id parameters = payload;
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
    
}

- (AFHTTPRequestOperation*)opUpdateProfile:(NSDictionary*)newProfile
                                  ofSender:(EntityLoginInfo*)loginInfo
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    
    NSString* apiUrl = [NSString stringWithFormat:kPathEmployeeProfile, loginInfo.schoolId, loginInfo.phone];
    
    NSDictionary* profile = @{
                              @"id":loginInfo.uid,
                              @"name":loginInfo.name,
                              @"phone":loginInfo.phone,
                              @"portrait":loginInfo.portrait,
                              @"gender":loginInfo.gender,
                              @"workgroup":loginInfo.workgroup,
                              @"workduty":loginInfo.workduty,
                              @"birthday":loginInfo.birthday,
                              @"school_id":loginInfo.schoolId,
                              @"login_name":loginInfo.loginName,
                              };
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary:profile];
    [parameters addEntriesFromDictionary:newProfile];

    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opGetAssessmentsOfChild:(EntityChildInfo*)childInfo
                                              from:(long long)fromId
                                                to:(long long)toId
                                              most:(NSInteger)most
                                           success:(SuccessResponseHandler)success
                                           failure:(FailureResponseHandler)failure {
    NSParameterAssert(childInfo);
    NSString* apiUrl = [NSString stringWithFormat:kPathChildAssess, childInfo.schoolId, childInfo.childId];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    AFHTTPRequestOperation* op = [self.opManager GET:apiUrl
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opResetPswdOfAccount:(NSString*)accountName
                                    withNewPswd:(NSString*)newPswd
                                    andAuthCode:(NSString*)authCode
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure {
    NSParameterAssert(accountName && newPswd && authCode);
    
    NSString* apiUrl = kResetPswd;
    
    NSDictionary* parameters = @{@"account_name": accountName,
                                 @"authcode": authCode,
                                 @"new_password": newPswd};
    
    AFHTTPRequestOperation* op = [self.opManager POST:apiUrl
                                           parameters:parameters
                                              success:success
                                              failure:failure];
    return op;
}

- (AFHTTPRequestOperation*)opGetSmsCode:(NSString*)phone
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSParameterAssert(phone);
    
    NSString* path = [NSString stringWithFormat:kGetSmsCodePath, phone];
    
    
    NSDictionary* parameters = nil;
    
    AFHTTPRequestOperation* op = [self.opManager GET:path
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    return op;
}

@end

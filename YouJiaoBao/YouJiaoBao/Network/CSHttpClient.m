//
//  CSHttpClient.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSHttpClient.h"
#import "CSHttpUrls.h"
#import "ModelAssessment.h"
#import "CSEngine.h"

@interface CSHttpClient ()

@property (nonatomic, strong) AFHTTPSessionManager* opManager;
@property (nonatomic, strong) AFHTTPSessionManager* opQiniuManager;
@property (nonatomic, strong) AFHTTPSessionManager* opiTunesManager;

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
- (AFHTTPSessionManager*)opManager {
    if (_opManager == nil) {
        _opManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kServerHostUsing]];
        
        _opManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
        [_opManager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"source"];
        _opManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [_opManager.requestSerializer setValue:version forHTTPHeaderField:@"versioncode"];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opManager.responseSerializer = responseSerializer;
        
        _opManager.securityPolicy.allowInvalidCertificates = YES;
        _opManager.securityPolicy.validatesDomainName = NO;
    }
    
    return _opManager;
}

- (AFHTTPSessionManager*)opQiniuManager {
    if (_opQiniuManager == nil) {
        NSURLSessionConfiguration* sessionConfiguration = nil;
        _opQiniuManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kQiniuUploadServerHost]
                           sessionConfiguration:sessionConfiguration];
        
        _opQiniuManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opQiniuManager.responseSerializer = responseSerializer;
        
        _opQiniuManager.securityPolicy.allowInvalidCertificates = YES;
        _opQiniuManager.securityPolicy.validatesDomainName = NO;
    }
    
    return _opQiniuManager;
}

- (AFHTTPSessionManager*)opiTunesManager {
    if (_opiTunesManager == nil) {
        _opiTunesManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kQiniuUploadServerHost]];
        
        _opiTunesManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
        
        AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        responseSerializer.removesKeysWithNullValues = YES;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
        _opiTunesManager.responseSerializer = responseSerializer;
        
        _opiTunesManager.securityPolicy.allowInvalidCertificates = YES;
    }
    
    return _opiTunesManager;
}

- (NSURLSessionDataTask*)opUploadToQiniu:(NSData*)data
                                 withKey:(NSString*)key
                                withMime:(NSString*)mime
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    
    id _success = ^(NSURLSessionDataTask *task, id responseObject) {
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
            
            failure(task, error);
        }
    };
    
    id _failure = ^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    };
    
    
    NSURLSessionDataTask* task = [self _opGetUploadTokenWithKey:key
                                                        success:_success
                                                        failure:_failure];
    
    return task;
}

- (NSURLSessionDataTask*)_opGetUploadTokenWithKey:(NSString*)key
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure {
    NSParameterAssert(key);
    
    NSString* path = kUploadFileTokenPath;
    
    NSDictionary* parameters = @{@"bucket": kQiniuBucket,
                                 @"key": key};
    
    NSURLSessionDataTask* task =[self.opManager GET:path
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    
    return task;
}

- (NSURLSessionDataTask*)_opDoUploadToQiniuWithData:(NSData*)data
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
    
    NSURLSessionDataTask* task =[self.opQiniuManager POST:@"/"
                                               parameters:nil
                                constructingBodyWithBlock:_formDataBlock
                                                 progress:nil
                                                  success:success
                                                  failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opLoginWithUsername:(NSString*)username
                                    password:(NSString*)password
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure {
    NSParameterAssert(username && password);
    
    id parameters = @{@"account_name": username,
                      @"password" : password};
    
    NSURLSessionDataTask* task =[self.opManager POST:kPathEmployeeLogin
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    
    return task;
}

- (NSURLSessionDataTask*)opGetClassListOfKindergarten:(NSInteger)schoolId
                                       withEmployeeId:(NSString*)employeePhone
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure {
    NSParameterAssert(employeePhone);
    
    id parameters = @{@"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathEmployeeManagedClass, @(schoolId), employeePhone];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    
    return task;
}

- (NSURLSessionDataTask*)opGetSchoolInfo:(NSInteger)schoolId
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure; {
    id parameters = @{};
    
    NSString* apiUrl = [NSString stringWithFormat:kGetSchoolInfoPath, @(schoolId)];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    
    return task;
}

- (NSURLSessionDataTask*)opGetChildListOfKindergarten:(NSInteger)schoolId
                                        withClassList:(NSArray*)classIdList
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure {
    id parameters = @{@"class_id": [classIdList componentsJoinedByString:@","],
                      @"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenChildList, @(schoolId)];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
    
}

- (NSURLSessionDataTask*)opGetDailyLogListOfKindergarten:(NSInteger)schoolId
                                           withClassList:(NSArray*)classIdList
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure {
    id parameters = @{@"class_id": [classIdList componentsJoinedByString:@","]};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenDailylogList, @(schoolId)];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
    
}

- (NSURLSessionDataTask*)opGetSessionListOfKindergarten:(NSInteger)schoolId
                                          withClassList:(NSArray*)classIdList
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure {
    id parameters = @{@"class_id": [classIdList componentsJoinedByString:@","],
                      @"connected" : @"true"};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenSessionList, @(schoolId)];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetRelationshipOfChild:(NSString*)childId
                                   inKindergarten:(NSInteger)schoolId
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure {
    id parameters = @{@"child": childId};
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenRelationship, @(schoolId)];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
    
}

- (NSURLSessionDataTask*)opGetRelationshipOfClasses:(NSArray*)classIdList
                                     inKindergarten:(NSInteger)schoolId
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    id parameters = @{};
    if (classIdList.count > 0) {
        parameters = @{@"class_id": [classIdList componentsJoinedByString:@","]};
    }
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenRelationship, @(schoolId)];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
    
}

- (NSURLSessionDataTask*)opGetNewsOfClasses:(NSArray*)classIdList
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
    
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenPostNewsV2,
                        @(schoolId),
                        session.loginInfo._id];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetAssignmentsOfClasses:(NSArray*)classIdList
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
    
    NSURLSessionDataTask* task = [self.opManager GET:apiUrl
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
    
}

- (NSURLSessionDataTask*)opChangePassword:(NSString*)newPswd
                              withOldPswd:(NSString*)oldPswd
                               forAccount:(CBLoginInfo*)loginInfo
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure {
    NSParameterAssert(newPswd);
    NSParameterAssert(oldPswd);
    NSParameterAssert(loginInfo);
    
    NSString* apiUrl = [NSString stringWithFormat:kChangePasswordPath, loginInfo.school_id, loginInfo.phone];
    
    NSDictionary* parameters = @{@"employee_id": loginInfo._id,
                                 @"school_id" : loginInfo.school_id,
                                 @"phone" : loginInfo.phone,
                                 @"login_name" : loginInfo.login_name,
                                 @"old_password": oldPswd,
                                 @"new_password": newPswd};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opSendFeedback:(NSString*)account
                            withContent:(NSString*)msgContent
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSParameterAssert(account);
    NSParameterAssert(msgContent);
    
    NSString* apiUrl = kFeedbackPath;
    
    NSDictionary* parameters = @{@"phone": account,
                                 @"content": msgContent,
                                 @"source": @"ios_teacher"};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}


- (NSURLSessionDataTask*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
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
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
                                        withSenderId:(NSString*)senderId
                                     withChildIdList:(NSArray*)childIdList
                                         withContent:(NSString*)content
                                    withImageUrlList:(NSArray*)imgUrlList
                                        withVideoUrl:(NSString*)videoUrl
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure {
    
    NSString* childIdListString = [childIdList componentsJoinedByString:@","];
    NSString* apiUrl = [NSString stringWithFormat:kPostBatchHistoryPath, @(kindergarten), childIdListString];
    
    id msgSender = @{@"id": senderId, @"type": @"t"};
    
    NSMutableArray* mediumList = [NSMutableArray array];
    for (NSString* urlString in imgUrlList) {
        [mediumList addObject:@{@"url": urlString, @"type": @"image"}];
    }
    
    if (videoUrl.length > 0) {
        [mediumList addObject:@{@"url": videoUrl, @"type": @"video"}];
    }
    
    NSDictionary* parameters = @{@"topic": [childIdList firstObject],
                                 @"content": content ? content : @"",
                                 @"medium" : mediumList,
                                 @"sender": msgSender};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opPostNewsOfKindergarten:(NSInteger)kindergarten
                                       withSender:(CBLoginInfo*)senderInfo
                                      withClassId:(NSNumber*)classId
                                      withContent:(NSString*)content
                                        withTitle:(NSString*)title
                                 withImageUrlList:(NSArray*)imgUrlList
                                         withTags:(NSArray*)tags
                             withRequriedFeedback:(BOOL)requriedFeedback
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure {
    NSString* apiUrl = [NSString stringWithFormat:kPathKindergartenPostNewsV2, @(kindergarten), senderInfo._id];
    
    NSString* imgUrl = [imgUrlList firstObject];
    
    NSDictionary* parameters = @{@"school_id" : @(kindergarten),
                                 @"content": content ? content : @"",
                                 @"title": title ? title : @"",
                                 @"published" : @(YES),
                                 @"class_id" : classId,
                                 @"publisher_id": senderInfo._id,
                                 @"image" : imgUrl ? imgUrl : @"",
                                 @"tags": tags ? tags : @[],
                                 @"feedback_required" : @(requriedFeedback)};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opPostAssignmentOfKindergarten:(NSInteger)kindergarten
                                             withSender:(CBLoginInfo*)senderInfo
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
                                 @"publisher_id" : senderInfo._id,
                                 @"icon_url" : imgUrl ? imgUrl : @""};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opCheckUpdates:(NSString*)appId
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSString* apiUrl = @"/lookup";
    NSDictionary* parameters = @{@"id": appId};
    
    NSURLSessionDataTask* task = [self.opiTunesManager POST:apiUrl
                                                 parameters:parameters
                                                   progress:nil
                                                    success:success
                                                    failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetTopicMsgsOfChild:(NSString*)childId
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
    
    NSURLSessionDataTask* task = [self.opManager GET:apiUrl
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opDeleteTopicMsgs:(long long)msgId
                                   ofChild:(NSString*)childId
                            inKindergarten:(NSInteger)kindergarten
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(childId);
    
    NSString* apiUrl = [NSString stringWithFormat:kTopicIdPath, @(kindergarten), childId, @(msgId)];
    
    NSMutableDictionary* parameters = nil;
    
    NSURLSessionDataTask* task = [self.opManager DELETE:apiUrl
                                             parameters:parameters
                                                success:success
                                                failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opSendTopicMsg:(NSString*)msgBody
                             withSender:(CBLoginInfo*)senderInfo
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
    
    id msgSender = @{@"id": senderInfo._id,
                     @"type": @"t"};
    
    NSDictionary* parameters = @{@"topic": childId,
                                 @"timestamp": @(timestamp),
                                 @"content": msgBody ? msgBody : @"",
                                 @"media": msgMedia,
                                 @"sender": msgSender};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetTopicMsgSender:(NSString*)senderId
                                      ofType:(NSString*)senderType
                              inKindergarten:(NSInteger)kindergarten
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure {
    NSParameterAssert(senderId && senderType);
    
    NSString* apiUrl = [NSString stringWithFormat:kTopicSenderPath, @(kindergarten), senderId];
    
    NSDictionary* parameters = @{@"type": senderType};
    
    NSURLSessionDataTask* task = [self.opManager GET:apiUrl
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opSendAssessment:(NSArray*)assessmentList
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
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
    
}

- (NSURLSessionDataTask*)opUpdateProfile:(NSDictionary*)newProfile
                                ofSender:(CBLoginInfo*)loginInfo
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    
    NSString* apiUrl = [NSString stringWithFormat:kPathEmployeeProfile, loginInfo.school_id, loginInfo.phone];
    
    NSDictionary* profile = @{
                              @"id":loginInfo._id,
                              @"name":loginInfo.name,
                              @"phone":loginInfo.phone,
                              @"portrait":loginInfo.portrait,
                              @"gender":loginInfo.gender,
                              @"workgroup":loginInfo.workgroup,
                              @"workduty":loginInfo.workduty,
                              @"birthday":loginInfo.birthday,
                              @"school_id":loginInfo.school_id,
                              @"login_name":loginInfo.login_name,
                              };
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary:profile];
    [parameters addEntriesFromDictionary:newProfile];
    
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetAssessmentsOfChild:(NSString*)childId
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(long long)fromId
                                              to:(long long)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure {
    NSParameterAssert(childId);
    NSString* apiUrl = [NSString stringWithFormat:kPathChildAssess, @(kindergarten), SAFE_STRING(childId)];
    
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
    
    NSURLSessionDataTask* task = [self.opManager GET:apiUrl
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opResetPswdOfAccount:(NSString*)accountName
                                  withNewPswd:(NSString*)newPswd
                                  andAuthCode:(NSString*)authCode
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure {
    NSParameterAssert(accountName && newPswd && authCode);
    
    NSString* apiUrl = kResetPswd;
    NSDictionary* parameters = @{@"account_name": accountName,
                                 @"authcode": authCode,
                                 @"new_password": newPswd};
    
    NSURLSessionDataTask* task = [self.opManager POST:apiUrl
                                           parameters:parameters
                                             progress:nil
                                              success:success
                                              failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetSmsCode:(NSString*)phone
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure {
    NSParameterAssert(phone);
    
    NSString* path = [NSString stringWithFormat:kGetSmsCodePath, phone];
    NSDictionary* parameters = nil;
    
    NSURLSessionDataTask* task = [self.opManager GET:path
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetNewsReaders:(NSNumber*)newsId
                           inKindergarten:(NSInteger)schoolId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure {
    NSParameterAssert(newsId);
    
    NSString* path = [NSString stringWithFormat:kKindergartenNewsMarkedPathV2, @(schoolId), newsId];
    NSDictionary* parameters = nil;
    NSURLSessionDataTask* task = [self.opManager GET:path
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opDeleteNews:(NSNumber*)newsId
                       inKindergarten:(NSInteger)schoolId
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure {
    NSParameterAssert(newsId);
    
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    NSString* path = [NSString stringWithFormat:kDeleteNewsPath, @(schoolId), session.loginInfo._id, newsId];
    NSDictionary* parameters = nil;
    NSURLSessionDataTask* task = [self.opManager DELETE:path
                                             parameters:parameters
                                                success:success
                                                failure:failure];
    return task;
}

- (NSURLSessionDataTask*)opGetIneligibleClassOfKindergarten:(NSInteger)kindergarten
                                               withSenderId:(NSString*)senderId
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kKindergartenIneligibleClassPathV3, @(kindergarten), senderId];
    NSDictionary* parameters = nil;
    NSURLSessionDataTask* task = [self.opManager GET:path
                                          parameters:parameters
                                            progress:nil
                                             success:success
                                             failure:failure];
    return task;
}

- (NSURLSessionDataTask*)reqGetClassesOfKindergarten:(NSInteger)kindergarten
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kCBClassesURL, @(kindergarten)];
    
    NSMutableDictionary* parameters = nil;
    
    return [self.opManager GET:path
                    parameters:parameters
                      progress:nil
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)reqGetTeachersOfKindergarten:(NSInteger)kindergarten
                                          withClassId:(NSInteger)classId
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure {
    NSString* path = nil;
    if (classId > 0) {
        path = [NSString stringWithFormat:kCBTeachersURL, @(kindergarten), @(classId)];
    }
    else {
        path = [NSString stringWithFormat:kCBEmployeesURL, @(kindergarten)];
    }
    
    NSMutableDictionary* parameters = nil;
    
    return [self.opManager GET:path
                    parameters:parameters
                      progress:nil
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)reqGetRelationshipsOfKindergarten:(NSInteger)kindergarten
                                               withClassId:(NSInteger)classId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetFamilyRelationshipPath, @(kindergarten)];
    
    NSDictionary* parameters = @{};
    if (classId > 0) {
        parameters = @{@"class_id": @(classId)};
    }
    
    return [self.opManager GET:path
                    parameters:parameters
                      progress:nil
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)reqGetBandListOfKindergarten:(NSInteger)kindergarten
                                          withClassId:(NSInteger)classId
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kIMBanURLV8, @(kindergarten), @(classId)];
    
    NSDictionary* parameters = @{};
    
    return [self.opManager GET:path
                    parameters:parameters
                      progress:nil
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)reqAddBandUser:(NSString*)imUser
                         inKindergarten:(NSInteger)kindergarten
                            withClassId:(NSInteger)classId
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kIMBanURLV8, @(kindergarten), @(classId)];
    
    NSDictionary* parameters = @{@"id":SAFE_STRING(imUser),
                                 @"minute":@(99999)};
    
    return [self.opManager POST:path
                     parameters:@[parameters]
                       progress:nil
                        success:success
                        failure:failure];
    
}

- (NSURLSessionDataTask*)reqDeleteBandUser:(NSString*)imUser
                            inKindergarten:(NSInteger)kindergarten
                               withClassId:(NSInteger)classId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kIMBanIdURLV8, @(kindergarten), @(classId), SAFE_STRING(imUser)];
    
    NSDictionary* parameters = @{};
    
    return [self.opManager DELETE:path
                       parameters:parameters
                          success:success
                          failure:failure];
}

- (NSURLSessionDataTask*)reqGetiIneligibleClass:(NSInteger)employeeId
                                 inKindergarten:(NSInteger)kindergarten
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kKindergartenIneligibleClassPathV3, @(kindergarten), @(employeeId)];
    
    NSDictionary* parameters = @{};
    
    return [self.opManager GET:path
                    parameters:parameters
                      progress:nil
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)reqIMJoinGroupOfKindergarten:(NSInteger)kindergarten
                                          withClassId:(NSInteger)classId
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kIMGroupURLV8, @(kindergarten), @(classId)];
    
    NSDictionary* parameters = @{};
    
    return [self.opManager POST:path
                     parameters:parameters
                       progress:nil
                        success:success
                        failure:failure];
}

- (NSURLSessionDataTask*)reqGetHistoryList:(NSString*)employeeId
                            inKindergarten:(NSInteger)kindergarten
                                      from:(NSNumber*)from
                                        to:(NSNumber*)to
                                      most:(NSNumber*)most
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (from) {
        [parameters setObject:from forKey:@"from"];
    }
    
    if (to) {
        [parameters setObject:to forKey:@"to"];
    }
    
    if (most) {
        [parameters setObject:most forKey:@"most"];
    }
    
    NSString* apiUrl = [NSString stringWithFormat:kGetHistoryListURL,
                        @(kindergarten),
                        employeeId];
    
    NSURLSessionDataTask* task =[self.opManager GET:apiUrl
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
    return task;
    
    
}

- (NSURLSessionDataTask*)reqGetConfigOfKindergarten:(NSInteger)kindergarten
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetKindergartenConfigurePath, @(kindergarten)];
    
    NSDictionary* parameters = @{};
    
    return [self.opManager GET:path
                    parameters:parameters
                      progress:nil
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)reqHideGroupMsgs:(NSArray*)msgUids
                           inKindergarten:(NSInteger)kindergarten
                              withClassId:(NSInteger)classId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kIMHideGroupMsgsURLV8, @(kindergarten), @(classId)];
    
    NSMutableArray* parameters = [NSMutableArray array];
    for (NSString* msgUid in msgUids) {
        [parameters addObject:@{@"id":msgUid, @"class_id":@(classId), @"school_id":@(kindergarten)}];
    }
    
    return [self.opManager POST:path
                   parameters:parameters
                     progress:nil
                      success:success
                      failure:failure];
}

- (NSURLSessionDataTask*)reqHidePrivateMsgs:(NSArray*)msgUids
                             inKindergarten:(NSInteger)kindergarten
                               withTargetId:(NSString*)targetId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kIMHidePrivateMsgsURLV8, @(kindergarten)];
    
    
    NSMutableArray* parameters = [NSMutableArray array];
    for (NSString* msgUid in msgUids) {
        [parameters addObject:@{@"id":msgUid, @"user_id":targetId, @"school_id":@(kindergarten)}];
    }
    
    return [self.opManager POST:path
                   parameters:parameters
                     progress:nil
                      success:success
                      failure:failure];
}

@end
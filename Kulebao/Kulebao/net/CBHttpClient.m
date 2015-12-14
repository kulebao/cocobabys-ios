//
//  CBHttpClient.m
//  youlebao
//
//  Created by WangXin on 11/8/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBHttpClient.h"
#import "CSKuleURLCache.h"
#import "CSKulePreferences.h"
#import "BPush.h"
#import "CSAppDelegate.h"
#import "CBHTTPRequestOperationManager.h"

@interface CBHttpClient () {
    NSMutableDictionary* _senderProfiles;
}

@property (nonatomic, strong) CBHTTPRequestOperationManager* httpCobabys;
@property (nonatomic, strong) AFHTTPRequestOperationManager* httpQiniu;
@property (nonatomic, strong) AFHTTPRequestOperationManager* httpITunes;

@property (nonatomic, strong, readonly) CSKuleLoginInfo* loginInfo;

@end

@implementation CBHttpClient

+ (instancetype)sharedInstance {
    static CBHttpClient* s_instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [CBHttpClient new];
    });
    
    return s_instance;
}

- (id)init {
    if (self = [super init]) {
        if (_senderProfiles == nil) {
            _senderProfiles = [NSMutableDictionary dictionary];
        }
        else {
            [_senderProfiles removeAllObjects];
        }
        
        [self setupHttpClients];
    }
    
    return self;
}

- (CSKuleLoginInfo*)loginInfo {
    return gApp.engine.loginInfo;
}

- (void)setupHttpClients {
    NSString* homeDir = NSHomeDirectory();
    NSString* cachePath = [homeDir stringByAppendingPathComponent:@"Documents/Kule-Cache"];
    
    CSKuleURLCache* cache = [[CSKuleURLCache alloc] initWithMemoryCapacity:1024
                                                              diskCapacity:512*1024*1024
                                                                  diskPath:cachePath];
    [CSKuleURLCache setSharedURLCache:cache];
    
    CSKulePreferences* preferences = [CSKulePreferences defaultPreferences];
    
    
    NSDictionary* serverInfo = [preferences getServerSettings];
    NSString* cobabysUrlString = serverInfo[@"url"];
    if(cobabysUrlString.length == 0) {
        cobabysUrlString = kServerHostForProd;
    }
    
    if (_httpCobabys == nil) {
        _httpCobabys = [[CBHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:cobabysUrlString]];
    }
    _httpCobabys.securityPolicy.allowInvalidCertificates = YES;
    _httpCobabys.securityPolicy.validatesDomainName = NO;
    
    AFHTTPRequestSerializer* requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
    requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [requestSerializer setValue:version forHTTPHeaderField:@"versioncode"];
    [requestSerializer setValue:@"ios" forHTTPHeaderField:@"source"];
    _httpCobabys.requestSerializer = requestSerializer;
    
    AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    responseSerializer.removesKeysWithNullValues = YES;
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    _httpCobabys.responseSerializer = responseSerializer;
    
    
    if (_httpQiniu == nil) {
        NSURL* qiniuBaseUrl = [NSURL URLWithString:kQiniuUploadServerHost];
        _httpQiniu = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:qiniuBaseUrl];
        _httpQiniu.securityPolicy.allowInvalidCertificates = YES;
        _httpQiniu.securityPolicy.validatesDomainName = NO;
    }
    _httpQiniu.securityPolicy.allowInvalidCertificates = YES;
    _httpQiniu.securityPolicy.validatesDomainName = NO;
    
    requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
    requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    //[requestSerializer setValue:@"ios" forHTTPHeaderField:@"source"];
    _httpQiniu.requestSerializer = requestSerializer;
    
    responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    responseSerializer.removesKeysWithNullValues = YES;
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    _httpQiniu.responseSerializer = responseSerializer;
    
    if (_httpITunes == nil) {
        NSURL* qiniuBaseUrl = [NSURL URLWithString:@"http://itunes.apple.com"];
        _httpITunes = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:qiniuBaseUrl];
        _httpITunes.securityPolicy.allowInvalidCertificates = YES;
        _httpITunes.securityPolicy.validatesDomainName = NO;
    }
    _httpITunes.securityPolicy.allowInvalidCertificates = YES;
    _httpITunes.securityPolicy.validatesDomainName = NO;
    
    requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
    requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    //[requestSerializer setValue:@"ios" forHTTPHeaderField:@"source"];
    _httpITunes.requestSerializer = requestSerializer;
    
    responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    responseSerializer.removesKeysWithNullValues = YES;
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    _httpITunes.responseSerializer = responseSerializer;
}

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path {
    NSURL* url = nil;
    if (path.length > 0) {
        if ([path hasPrefix:@"http"]
            || [path hasPrefix:@"https"]) {
            url = [NSURL URLWithString:path];
        }
        else {
            url = [NSURL URLWithString:path
                         relativeToURL:_httpCobabys.baseURL];
        }
    }
    
    return url;
}

#pragma mark - Uploader
- (AFHTTPRequestOperation*)reqUploadToQiniu:(NSData*)data
                                    withKey:(NSString*)key
                                   withMime:(NSString*)mime
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure {
    NSParameterAssert(data);
    NSParameterAssert(key);
    NSParameterAssert(mime);
    
    return [self reqGetUploadTokenWithKey:key success:^(AFHTTPRequestOperation *operation, id dataJson) {
        NSString* token = [dataJson valueForKeyNotNull:@"token"];
        
        if (token) {
            [self reqUploadQiniuWithData:data
                               withToken:token
                                  andKey:key
                                 andMime:mime
                                 success:success
                                 failure:failure];
        }
        else {
            NSError* error = [NSError errorWithDomain:@"CSKit"
                                                 code:-8888
                                             userInfo: @{NSLocalizedDescriptionKey:@"Invalid Token."}];
            
            failure(operation, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}

#pragma mark - Check update on iTunes
- (AFHTTPRequestOperation*)reqCheckITunesUpdates:(NSString*)appId
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure {
    NSString* path = @"/lookup";
    NSDictionary* parameters = @{@"id": appId};
    return [_httpITunes POST:path parameters:parameters success:success failure:success];
}

- (AFHTTPRequestOperation*)reqGetUploadTokenWithKey:(NSString*)key
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    NSParameterAssert(key);
    
    NSString* path = kUploadFileTokenPath;
    NSDictionary* parameters = @{@"bucket": kQiniuBucket,
                                 @"key": key};
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqUploadQiniuWithData:(NSData*)data
                                        withToken:(NSString*)token
                                           andKey:(NSString*)key
                                          andMime:(NSString*)mime
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure {
    
    return [_httpQiniu POST:@"/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:mime];
        [formData appendPartWithFormData:[key dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
        [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    } success:success failure:failure];
}

#pragma mark - HTTP Request
- (AFHTTPRequestOperation*)reqCheckPhoneNum:(NSString*)mobile
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure {
    NSString* path = kCheckPhoneNumPath;
    
    
    
    NSDictionary* parameters = @{@"phonenum":mobile};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqLogin:(NSString*)mobile
                           withPswd:(NSString*)password
                            success:(SuccessResponseHandler)success
                            failure:(FailureResponseHandler)failure {
    NSParameterAssert(mobile);
    NSParameterAssert(password);
    
    NSString* path = kLoginPath;
    
    
    
    NSDictionary* parameters = @{@"account_name":mobile,
                                 @"password":password};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqReceiveBindInfo:(NSString*)mobile
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure {
    NSParameterAssert(mobile);
    
    NSString* path = kReceiveBindInfoPath;
    
    
    
    NSDictionary* parameters = nil;
    
    if ([BPush getChannelId] && [BPush getUserId]) {
        parameters = @{@"phonenum": mobile,
                       @"user_id": [BPush getUserId],
                       @"channel_id": [BPush getChannelId],
                       @"access_token": self.loginInfo.accessToken ? self.loginInfo.accessToken : @"",
                       @"device_type": @"ios"};
    }
    else {
        CSLog(@"");
        parameters = @{@"phonenum": mobile,
                       @"user_id": @"",
                       @"channel_id": @"",
                       @"access_token":self.loginInfo.accessToken ? self.loginInfo.accessToken : @"",
                       @"device_type": @"ios"};
    }
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqUnbindWithSuccess:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure {
    NSString* path = kReceiveBindInfoPath;
    
    
    
    NSDictionary* parameters = nil;
    
    parameters = @{@"phonenum": self.loginInfo.accountName,
                   @"user_id": @"",
                   @"channel_id": @"",
                   @"access_token": self.loginInfo.accessToken ? self.loginInfo.accessToken : @"",
                   @"device_type": @"ios"};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
    
}

- (AFHTTPRequestOperation*)reqChangePassword:(NSString*)newPswd
                                 withOldPswd:(NSString*)oldPswd
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure {
    NSParameterAssert(newPswd);
    NSParameterAssert(oldPswd);
    
    NSString* path = kChangePasswordPath;
    
    
    
    NSDictionary* parameters = @{@"account_name": self.loginInfo.accountName,
                                 @"old_password": oldPswd,
                                 @"new_password": newPswd};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetFamilyRelationship:(NSString*)mobile
                                     inKindergarten:(NSInteger)kindergarten
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    NSParameterAssert(mobile);
    
    NSString* path = [NSString stringWithFormat:kGetFamilyRelationshipPath, @(kindergarten)];
    
    
    
    NSDictionary* parameters = @{@"parent": mobile};
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetChildRelationship:(NSString*)childId
                                    inKindergarten:(NSInteger)kindergarten
                                           success:(SuccessResponseHandler)success
                                           failure:(FailureResponseHandler)failure {
    NSParameterAssert(childId);
    
    NSString* path = [NSString stringWithFormat:kGetFamilyRelationshipPath, @(kindergarten)];
    
    
    
    NSDictionary* parameters = @{@"child": childId};
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqUpdateChildInfo:(CSKuleChildInfo*)childInfo
                               inKindergarten:(NSInteger)kindergarten
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure {
    NSParameterAssert(childInfo);
    
    NSString* path = [NSString stringWithFormat:kChildInfoPath, @(kindergarten), childInfo.childId];
    
    
    
    NSDictionary* parameters = @{@"name": childInfo.name,
                                 @"nick": childInfo.nick,
                                 @"birthday": childInfo.birthday,
                                 @"gender": @(childInfo.gender),
                                 @"portrait": childInfo.portrait,
                                 @"class_id": @(childInfo.classId),
                                 @"child_id": childInfo.childId,
                                 @"class_name": childInfo.className,};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqUpdateParentInfo:(CSKuleParentInfo*)parentInfo
                                inKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure {
    NSParameterAssert(parentInfo);
    
    NSString* path = [NSString stringWithFormat:kUpdateParentInfoPath, @(kindergarten)];
    
    
    
    NSDictionary* parameters = @{
                                 @"parent_id": parentInfo.parentId,
                                 @"school_id": @(kindergarten),
                                 @"name": parentInfo.name,
                                 @"phone": parentInfo.phone,
                                 @"portrait": parentInfo.portrait,
                                 @"gender": @(parentInfo.gender),
                                 @"birthday": parentInfo.birthday,
                                 };
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetNewsOfKindergarten:(NSInteger)kindergarten
                                        withClassId:(NSInteger)classId
                                               from:(NSInteger)fromId
                                                 to:(NSInteger)toId
                                               most:(NSInteger)most
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kKindergartenNewsListPathV2, @(kindergarten)];
    
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    if (classId > 0) {
        [parameters setObject:@(classId) forKey:@"class_id"];
    }
    
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    [parameters setObject:@(1) forKey:@"tag"];
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetCookbooksOfKindergarten:(NSInteger)kindergarten
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kKindergartenCookbooksPath, @(kindergarten)];
    
    
    
    NSDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetAssignmentsOfKindergarten:(NSInteger)kindergarten
                                               withClassId:(NSInteger)classId
                                                      from:(NSInteger)fromId
                                                        to:(NSInteger)toId
                                                      most:(NSInteger)most
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kAssignmentListPath, @(kindergarten)];
    
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (classId > 0) {
        [parameters setObject:@(classId) forKey:@"class_id"];
    }
    
    if (fromId >= 0) {
        [parameters setObject:@(fromId) forKey:@"from"];
    }
    
    if (toId >= 0) {
        [parameters setObject:@(toId) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetSchedulesOfKindergarten:(NSInteger)kindergarten
                                             withClassId:(NSInteger)classId
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kSchedulesPath, @(kindergarten), @(classId)];
    
    
    
    NSDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
    
}

- (AFHTTPRequestOperation*)reqGetSchoolInfoOfKindergarten:(NSInteger)kindergarten
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kGetSchoolInfoPath, @(kindergarten)];
    
    
    
    NSDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
    
}

- (AFHTTPRequestOperation*)reqGetCheckInOutLogOfChild:(CSKuleChildInfo*)childInfo
                                       inKindergarten:(NSInteger)kindergarten
                                                 from:(NSTimeInterval)fromTimestamp
                                                   to:(NSTimeInterval)toTimestamp
                                                 most:(NSInteger)most
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure {
    NSParameterAssert(childInfo);
    
    NSString* path = [NSString stringWithFormat:kGetCheckInOutLogPath, @(kindergarten), childInfo.childId];
    
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    if (fromTimestamp >= 0) {
        [parameters setObject:@((long long)(fromTimestamp*1000)) forKey:@"from"];
    }
    
    if (toTimestamp >= 0) {
        [parameters setObject:@((long long)(toTimestamp*1000)) forKey:@"to"];
    }
    
    if (most >= 0) {
        [parameters setObject:@(most) forKey:@"most"];
    }
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqSendChatingMsg:(NSString*)msgBody
                                   withImage:(NSString*)imgUrl
                              toKindergarten:(NSInteger)kindergarten
                                retrieveFrom:(long long)fromId
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure {
    NSParameterAssert(msgBody || imgUrl); // 不能同时为空
    NSParameterAssert(self.loginInfo.accountName);
    
    NSString* path = [NSString stringWithFormat:kChatingPath, @(kindergarten), self.loginInfo.accountName];
    
    if (fromId >= 0) {
        path = [path stringByAppendingFormat:@"?retrieve_recent_from=%lld", fromId];
    }
    
    
    
    /*
     {"phone":"123456789","timestamp":1392967799188,"content":"谢谢你的鼓励","image":"http://suoqin-test.u.qiniudn.com/Fget0Tx492DJofAy-ZeUg1SANJ4X","sender":"带班老师"}
     */
    
    long long timestamp = [[NSDate date] timeIntervalSince1970]*1000;
    
    NSString* msgImage = @"";
    if (imgUrl.length > 0) {
        msgImage = [[self urlFromPath:imgUrl] absoluteString];
    }
    
    NSDictionary* parameters = @{@"phone": self.loginInfo.accountName,
                                 @"timestamp": @(timestamp),
                                 @"content": msgBody ? msgBody : @"",
                                 @"image": msgImage,
                                 @"sender": @""};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                                    from:(long long)fromId
                                                      to:(long long)toId
                                                    most:(NSInteger)most
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure {
    if (gApp.engine.currentRelationship == nil) {
        return nil;
    }
    
    NSParameterAssert(gApp.engine.currentRelationship.child);
    
    NSString* path = [NSString stringWithFormat:kTopicPath, @(kindergarten), gApp.engine.currentRelationship.child.childId];
    
    
    
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
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqDeleteTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                                   recordId:(long long)msgId
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(gApp.engine.currentRelationship.child);
    
    NSString* path = [NSString stringWithFormat:kTopicIdPath, @(kindergarten), gApp.engine.currentRelationship.child.childId, @(msgId)];
    
    NSMutableDictionary* parameters = nil;
    return [_httpCobabys DELETE:path
                     parameters:parameters
                        success:success
                        failure:failure];
}

- (AFHTTPRequestOperation*)reqSendTopicMsg:(NSString*)msgBody
                              withMediaUrl:(NSString*)mediaUrl
                               ofMediaType:(NSString*)mediaType
                            toKindergarten:(NSInteger)kindergarten
                              retrieveFrom:(long long)fromId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    NSParameterAssert(msgBody || mediaUrl); // 不能同时为空
    NSParameterAssert(gApp.engine.currentRelationship.child);
    
    
    NSString* path = [NSString stringWithFormat:kTopicPath, @(kindergarten), gApp.engine.currentRelationship.child.childId];
    
    if (fromId >= 0) {
        path = [path stringByAppendingFormat:@"?retrieve_recent_from=%lld", fromId];
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
        msgMedia = @{@"url": SAFE_STRING([[self urlFromPath:mediaUrl] absoluteString]),
                     @"type": mediaType};
    }
    
    id msgSender = @{@"id": gApp.engine.currentRelationship.parent.parentId,
                     @"type": @"p"};
    
    NSDictionary* parameters = @{@"topic": gApp.engine.currentRelationship.child.childId,
                                 @"timestamp": @(timestamp),
                                 @"content": msgBody ? msgBody : @"",
                                 @"media": msgMedia,
                                 @"sender": msgSender};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetAssessesOfChild:(CSKuleChildInfo*)childInfo
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(NSInteger)fromId
                                              to:(NSInteger)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(childInfo);
    
    NSString* path = [NSString stringWithFormat:kAssessPath, @(kindergarten), childInfo.childId];
    
    
    
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
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetSmsCode:(NSString*)phone
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    NSParameterAssert(phone);
    
    NSString* path = [NSString stringWithFormat:kGetSmsCodePath, phone];
    
    
    
    NSDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqBindPhone:(NSString*)phone
                                smsCode:(NSString*)authcode
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetSmsCodePath, phone];
    
    
    
    NSDictionary* parameters = @{@"phone": phone,
                                 @"code": authcode};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqResetPswd:(NSString*)account
                                smsCode:(NSString*)authcode
                            withNewPswd:(NSString*)newPswd
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure {
    
    NSParameterAssert(account);
    NSParameterAssert(authcode);
    NSParameterAssert(newPswd);
    
    NSString* path = kResetPswdPath;
    
    
    
    NSDictionary* parameters = @{@"account_name": account,
                                 @"authcode": authcode,
                                 @"new_password": newPswd};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
    
}

- (AFHTTPRequestOperation*)reqSendFeedback:(NSString*)account
                               withContent:(NSString*)msgContent
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure {
    NSParameterAssert(account);
    NSParameterAssert(msgContent);
    
    NSString* path = kFeedbackPath;
    
    
    
    NSDictionary* parameters = @{@"phone": account,
                                 @"content": msgContent,
                                 @"source": @"ios_parent"};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetEmployeeListOfKindergarten:(NSInteger)kindergarten
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetEmployeeInfoPath, @(kindergarten)];
    
    
    
    NSDictionary* parameters = @{};
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
    
}

- (AFHTTPRequestOperation*)reqGetSenderProfileOfKindergarten:(NSInteger)kindergarten
                                                  withSender:(CSKuleSenderInfo*)senderInfo
                                                    complete:(void (^)(id obj))complete {
    if (senderInfo.senderId.length > 0) {
        id obj = [_senderProfiles objectForKey:senderInfo.senderId];
        if (obj && complete) {
            complete(obj);
        }
        else if(obj == nil) {
            if ([senderInfo.type isEqualToString:@"t"] || [senderInfo.type isEqualToString:@"p"]) {
                NSString* path = [NSString stringWithFormat:kGetSenderInfoPath, @(kindergarten), senderInfo.senderId];
                
                
                
                NSDictionary* parameters = @{@"type": senderInfo.type};
                
                id success = ^(AFHTTPRequestOperation *operation, id dataJson) {
                    id profile = nil;
                    if ([senderInfo.type isEqualToString:@"t"]) {
                        profile = [CSKuleInterpreter decodeEmployeeInfo:dataJson];
                    }
                    else if ([senderInfo.type isEqualToString:@"p"]) {
                        profile = [CSKuleInterpreter decodeParentInfo:dataJson];
                    }
                    
                    if (profile) {
                        [_senderProfiles setObject:profile forKey:senderInfo.senderId];
                    }
                    
                    if (complete) {
                        complete(profile);
                    }
                };
                
                id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                };
                
                return [_httpCobabys GET:path
                              parameters:parameters
                                 success:success
                                 failure:failure];
            }
        }
    }
    
    return nil;
}


- (AFHTTPRequestOperation*)reqGetHistoryListOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                  fromDate:(NSDate*)fromDate
                                                    toDate:(NSDate*)toDate
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetHistoryListPath, @(kindergarten), childId];
    
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if (fromDate) {
        long long msec = [fromDate timeIntervalSince1970] * 1000;
        [parameters setObject:@(msec) forKey:@"from"];
    }
    
    if (toDate) {
        long long msec = [toDate timeIntervalSince1970] * 1000;
        [parameters setObject:@(msec) forKey:@"to"];
    }
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqPostHistoryOfKindergarten:(NSInteger)kindergarten
                                            withChildId:(NSString*)childId
                                            withContent:(NSString*)content
                                       withImageUrlList:(NSArray*)imgUrlList
                                           withVideoUrl:(NSString*)videoUrl
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetHistoryListPath, @(kindergarten), childId];
    
    
    
    id msgSender = @{@"id": gApp.engine.currentRelationship.parent.parentId,
                     @"type": @"p"};
    
    NSMutableArray* mediumList = [NSMutableArray array];
    for (NSString* urlString in imgUrlList) {
        [mediumList addObject:@{@"url": urlString, @"type": @"image"}];
    }
    
    if ((mediumList.count == 0) && videoUrl.length > 0) {
        [mediumList addObject:@{@"url": videoUrl, @"type": @"video"}];
    }
    
    NSDictionary* parameters = @{@"topic": childId,
                                 @"content": content ? content : @"",
                                 @"medium" : mediumList,
                                 @"sender": msgSender};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqDeleteHistoryOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                                 recordId:(long long)msgId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kDeleteHistoryListPath, @(kindergarten), childId, @(msgId)];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys DELETE:path
                     parameters:parameters
                        success:success
                        failure:failure];
}

- (AFHTTPRequestOperation*)reqGetVideoMemberListOfKindergarten:(NSInteger)kindergarten
                                                       success:(SuccessResponseHandler)success
                                                       failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kGetVideoMemberListPath, @(kindergarten)];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
    
}

- (AFHTTPRequestOperation*)reqGetVideoMemberOfKindergarten:(NSInteger)kindergarten
                                              withParentId:(NSString*)parentId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetVideoMemberPath, @(kindergarten), parentId];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetDefaultVideoMemberOfKindergarten:(NSInteger)kindergarten
                                                          success:(SuccessResponseHandler)success
                                                          failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetDefaultVideoMemberPath, @(kindergarten)];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqMarkAsRead:(CSKuleNewsInfo*)newsInfo
                                byParent:(CSKuleParentInfo*)parentInfo
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure {
    NSParameterAssert(newsInfo);
    NSParameterAssert(parentInfo);
    
    NSString* path = [NSString stringWithFormat:kKindergartenNewsMarkedPathV2, @(parentInfo.schoolId),
                      @(newsInfo.newsId)];
    
    NSDictionary* parameters = @{
                                 @"school_id": @(parentInfo.schoolId),
                                 @"name": parentInfo.name,
                                 @"phone": parentInfo.phone,
                                 @"portrait": parentInfo.portrait,
                                 @"gender": @(parentInfo.gender),
                                 @"birthday": parentInfo.birthday,
                                 @"parent_id": parentInfo.parentId,
                                 @"timestamp": @(parentInfo.timestamp),
                                 @"member_status": @(parentInfo.memberStatus),
                                 @"status": @(parentInfo.status)};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqQueryReadStatusOf:(CSKuleNewsInfo*)newsInfo
                                       byParent:(CSKuleParentInfo*)parentInfo
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure {
    NSParameterAssert(newsInfo);
    NSParameterAssert(parentInfo);
    
    NSString* path = [NSString stringWithFormat:kKindergartenNewsMarkedStatusPathV2,
                      @(parentInfo.schoolId),
                      @(newsInfo.newsId),
                      parentInfo.parentId];
    
    
    NSDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetBusLocationOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    
    NSString* path = [NSString stringWithFormat:kBusLocationPathV2, @(kindergarten), childId];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
    
}

- (AFHTTPRequestOperation*)reqGetShareTokenOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                             withRecordId:(NSInteger)recordId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetShareTokenV3, @(kindergarten), childId, @(recordId)];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetActivityListOfKindergarten:(NSInteger)kindergarten
                                                       from:(long long)fromId
                                                         to:(long long)toId
                                                       most:(NSInteger)most
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetActivityListV4, @(kindergarten)];
    
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
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetContractorListOfKindergarten:(NSInteger)kindergarten
                                                 withCategory:(NSInteger)category
                                                         from:(long long)fromId
                                                           to:(long long)toId
                                                         most:(NSInteger)most
                                                      success:(SuccessResponseHandler)success
                                                      failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetContractorListV4, @(kindergarten)];
    
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
    
    if (category >= 0) {
        [parameters setObject:@(category) forKey:@"category"];
    }
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetActivityListOfKindergarten:(NSInteger)kindergarten
                                           withContractorId:(NSInteger)contractorId
                                                       from:(long long)fromId
                                                         to:(long long)toId
                                                       most:(NSInteger)most
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetContractorActivityListV4, @(kindergarten), @(contractorId)];
    
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
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetEnrollmentOfKindergarten:(NSInteger)kindergarten
                                             withActivity:(NSInteger)activityId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetEnrollmentV4,
                      @(kindergarten),
                      @(activityId),
                      gApp.engine.currentRelationship.parent.parentId];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
    
}

- (AFHTTPRequestOperation*)reqPostEnrollmentOfKindergarten:(NSInteger)kindergarten
                                              withActivity:(CBActivityData*)activity
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kPostEnrollmentV4,
                      @(kindergarten),
                      @(activity.uid)];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@(activity.agent_id) forKey:@"agent_id"];
    [parameters setObject:@(activity.uid) forKey:@"activity_id"];
    [parameters setObject:@(gApp.engine.currentRelationship.parent.schoolId) forKey:@"school_id"];
    [parameters setObject:SAFE_STRING(gApp.engine.currentRelationship.parent.parentId) forKey:@"parent_id"];
    [parameters setObject:SAFE_STRING(gApp.engine.currentRelationship.parent.phone) forKey:@"contact"];
    [parameters setObject:SAFE_STRING(gApp.engine.currentRelationship.parent.name) forKey:@"name"];
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetInviteCodeWithHost:(NSString*)hostPhone
                                         andInvitee:(NSString*)smsPhone
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure{
    NSString* path = [NSString stringWithFormat:kGetInviteCode, smsPhone];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:hostPhone forKey:@"host"];
    [parameters setObject:smsPhone forKey:@"invitee"];
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqBindCardOfKindergarten:(NSInteger)kindergarten
                                         withCardNum:(NSString*)cardNum
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kBindCard, @(kindergarten), cardNum];
    
    
    NSDictionary* parameters = @{@"relationship": gApp.engine.currentRelationship.relationship,
                                 @"parent": @{
                                         @"phone":  gApp.engine.currentRelationship.parent.phone
                                         },
                                 @"child": @{
                                         @"child_id":  gApp.engine.currentRelationship.child.childId
                                         },
                                 @"id":@(gApp.engine.currentRelationship.uid)};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqCreateInvitationOfKindergarten:(NSInteger)kindergarten
                                                       phone:(NSString*)phone
                                                        name:(NSString*)name
                                                relationship:(NSString*)relationship
                                                    passcode:(NSString*)passcode
                                                     success:(SuccessResponseHandler)success
                                                     failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kCreateInvitation, @(kindergarten)];
    
    
    NSDictionary* parameters = @{@"from":@{
                                         @"parent_id": gApp.engine.currentRelationship.parent.parentId,
                                         @"school_id": @(kindergarten),
                                         @"name": gApp.engine.currentRelationship.parent.name,
                                         @"phone": gApp.engine.currentRelationship.parent.phone,
                                         @"portrait": gApp.engine.currentRelationship.parent.portrait,
                                         @"gender": @(0),
                                         @"birthday": @"",
                                         @"timestamp": @(gApp.engine.currentRelationship.parent.timestamp/1000),
                                         @"member_status": @(gApp.engine.currentRelationship.parent.memberStatus),
                                         @"status": @(1),
                                         @"company": @"",
                                         @"created_at": @(0),
                                         @"id": @(0)
                                         },
                                 @"to":@{
                                         @"phone": phone,
                                         @"name": name,
                                         @"relationship": relationship
                                         },
                                 @"code": @{
                                         @"phone": phone,
                                         @"code": passcode
                                         }};
    
    return [_httpCobabys POST:path
                   parameters:parameters
                      success:success
                      failure:failure];
}

- (AFHTTPRequestOperation*)reqGetClassesOfKindergarten:(NSInteger)kindergarten
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kCBClassesURL, @(kindergarten)];
    
    NSMutableDictionary* parameters = nil;
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetTeachersOfKindergarten:(NSInteger)kindergarten
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
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

- (AFHTTPRequestOperation*)reqGetRelationshipsOfKindergarten:(NSInteger)kindergarten
                                                 withClassId:(NSInteger)classId
                                                     success:(SuccessResponseHandler)success
                                                     failure:(FailureResponseHandler)failure {
    NSString* path = [NSString stringWithFormat:kGetFamilyRelationshipPath, @(kindergarten)];
    
    NSDictionary* parameters = @{};
    if (classId > 0) {
        parameters = @{@"class_id": @(classId)};
    }
    
    return [_httpCobabys GET:path
                  parameters:parameters
                     success:success
                     failure:failure];
}

@end

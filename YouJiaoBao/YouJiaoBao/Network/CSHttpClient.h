//
//  CSHttpClient.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "EntityLoginInfo.h"

typedef void (^SuccessResponseHandler) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FailureResponseHandler) (AFHTTPRequestOperation *operation, NSError *error);

@interface CSHttpClient : NSObject

+ (id)sharedInstance;

- (AFHTTPRequestOperation*)opUploadToQiniu:(NSData*)data
                                   withKey:(NSString*)key
                                  withMime:(NSString*)mime
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opLoginWithUsername:(NSString*)username
                                      password:(NSString*)password
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetClassListOfKindergarten:(NSInteger)schoolId
                                         withEmployeeId:(NSString*)employeePhone
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetChildListOfKindergarten:(NSInteger)schoolId
                                          withClassList:(NSArray*)classIdList
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetDailylogOfKindergarten:(NSInteger)schoolId
                                         withClassList:(NSArray*)classIdList
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetRelationshipOfChild:(NSString*)childId
                                     inKindergarten:(NSInteger)schoolId
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetNewsOfClasses:(NSArray*)classIdList
                               inKindergarten:(NSInteger)schoolId
                                         from:(NSNumber*)from
                                           to:(NSNumber*)to
                                         most:(NSNumber*)most
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetAssignmentsOfClasses:(NSArray*)classIdList
                                      inKindergarten:(NSInteger)schoolId
                                                from:(NSNumber*)from
                                                  to:(NSNumber*)to
                                                most:(NSNumber*)most
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opChangePassword:(NSString*)newPswd
                                withOldPswd:(NSString*)oldPswd
                                 forAccount:(EntityLoginInfo*)loginInfo
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opSendFeedback:(NSString*)account
                              withContent:(NSString*)msgContent
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
                                          withSenderId:(NSString*)senderId
                                           withChildId:(NSString*)childId
                                           withContent:(NSString*)content
                                      withImageUrlList:(NSArray*)imgUrlList
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;

@end

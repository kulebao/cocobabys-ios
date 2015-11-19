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
#import "CSHttpUrls.h"
#import "EntityChildInfo.h"

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

- (AFHTTPRequestOperation*)opGetDailyLogListOfKindergarten:(NSInteger)schoolId
                                             withClassList:(NSArray*)classIdList
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetSessionListOfKindergarten:(NSInteger)schoolId
                                            withClassList:(NSArray*)classIdList
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetRelationshipOfChild:(NSString*)childId
                                     inKindergarten:(NSInteger)schoolId
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetRelationshipOfClasses:(NSArray*)classIdList
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

- (AFHTTPRequestOperation*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
                                          withSenderId:(NSString*)senderId
                                       withChildIdList:(NSArray*)childIdList
                                           withContent:(NSString*)content
                                      withImageUrlList:(NSArray*)imgUrlList
                                          withVideoUrl:(NSString*)videoUrl
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;
//tags : 作业、备忘、活动 （校园公告即没有tag)
- (AFHTTPRequestOperation*)opPostNewsOfKindergarten:(NSInteger)kindergarten
                                         withSender:(EntityLoginInfo*)senderInfo
                                        withClassId:(NSNumber*)classId
                                        withContent:(NSString*)content
                                          withTitle:(NSString*)title
                                   withImageUrlList:(NSArray*)imgUrlList
                                           withTags:(NSArray*)tags
                               withRequriedFeedback:(BOOL)requriedFeedback
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opPostAssignmentOfKindergarten:(NSInteger)kindergarten
                                               withSender:(EntityLoginInfo*)senderInfo
                                              withClassId:(NSNumber*)classId
                                              withContent:(NSString*)content
                                                withTitle:(NSString*)title
                                         withImageUrlList:(NSArray*)imgUrlList
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opCheckUpdates:(NSString*)appId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetTopicMsgsOfChild:(NSString*)childId
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(long long)fromId
                                              to:(long long)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opDeleteTopicMsgs:(long long)msgId
                                     ofChild:(NSString*)childId
                              inKindergarten:(NSInteger)kindergarten
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opSendTopicMsg:(NSString*)msgBody
                               withSender:(EntityLoginInfo*)senderInfo
                             withMediaUrl:(NSString*)mediaUrl
                              ofMediaType:(NSString*)mediaType
                                  ofChild:(NSString*)childId
                           inKindergarten:(NSInteger)kindergarten
                             retrieveFrom:(long long)fromId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetTopicMsgSender:(NSString*)senderId
                                        ofType:(NSString*)senderType
                                inKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opSendAssessment:(NSArray*)assessmentList
                             inKindergarten:(NSInteger)kindergarten
                                 fromSender:(NSString*)sender
                               withSenderId:(NSString*)senderId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opUpdateProfile:(NSDictionary*)newProfile
                                  ofSender:(EntityLoginInfo*)loginInfo
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetAssessmentsOfChild:(EntityChildInfo*)childInfo
                                              from:(long long)fromId
                                                to:(long long)toId
                                              most:(NSInteger)most
                                           success:(SuccessResponseHandler)success
                                           failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opResetPswdOfAccount:(NSString*)accountName
                                    withNewPswd:(NSString*)newPswd
                                    andAuthCode:(NSString*)authCode
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetSmsCode:(NSString*)phone
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetNewsReaders:(NSNumber*)newsId
                             inKindergarten:(NSInteger)schoolId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opDeleteNews:(NSNumber*)newsId
                         inKindergarten:(NSInteger)schoolId
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)opGetIneligibleClassOfKindergarten:(NSInteger)kindergarten
                                                 withSenderId:(NSString*)senderId
                                                      success:(SuccessResponseHandler)success
                                                      failure:(FailureResponseHandler)failure;

@end

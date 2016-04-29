//
//  CSHttpClient.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "CSHttpUrls.h"

@class CBLoginInfo;

typedef void (^SuccessResponseHandler) (NSURLSessionDataTask *task, id responseObject);
typedef void (^FailureResponseHandler) (NSURLSessionDataTask *task, NSError *error);

@interface CSHttpClient : NSObject

+ (id)sharedInstance;

- (NSURLSessionDataTask*)opUploadToQiniu:(NSData*)data
                                   withKey:(NSString*)key
                                  withMime:(NSString*)mime
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opLoginWithUsername:(NSString*)username
                                      password:(NSString*)password
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetClassListOfKindergarten:(NSInteger)schoolId
                                         withEmployeeId:(NSString*)employeePhone
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetSchoolInfo:(NSInteger)schoolId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetChildListOfKindergarten:(NSInteger)schoolId
                                          withClassList:(NSArray*)classIdList
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetDailyLogListOfKindergarten:(NSInteger)schoolId
                                             withClassList:(NSArray*)classIdList
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetSessionListOfKindergarten:(NSInteger)schoolId
                                            withClassList:(NSArray*)classIdList
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetRelationshipOfChild:(NSString*)childId
                                     inKindergarten:(NSInteger)schoolId
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetRelationshipOfClasses:(NSArray*)classIdList
                                       inKindergarten:(NSInteger)schoolId
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetNewsOfClasses:(NSArray*)classIdList
                               inKindergarten:(NSInteger)schoolId
                                         from:(NSNumber*)from
                                           to:(NSNumber*)to
                                         most:(NSNumber*)most
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetAssignmentsOfClasses:(NSArray*)classIdList
                                      inKindergarten:(NSInteger)schoolId
                                                from:(NSNumber*)from
                                                  to:(NSNumber*)to
                                                most:(NSNumber*)most
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opChangePassword:(NSString*)newPswd
                                withOldPswd:(NSString*)oldPswd
                                 forAccount:(CBLoginInfo*)loginInfo
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opSendFeedback:(NSString*)account
                              withContent:(NSString*)msgContent
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
                                          withSenderId:(NSString*)senderId
                                           withChildId:(NSString*)childId
                                           withContent:(NSString*)content
                                      withImageUrlList:(NSArray*)imgUrlList
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opPostHistoryOfKindergarten:(NSInteger)kindergarten
                                          withSenderId:(NSString*)senderId
                                       withChildIdList:(NSArray*)childIdList
                                           withContent:(NSString*)content
                                      withImageUrlList:(NSArray*)imgUrlList
                                          withVideoUrl:(NSString*)videoUrl
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;
//tags : 作业、备忘、活动 （校园公告即没有tag)
- (NSURLSessionDataTask*)opPostNewsOfKindergarten:(NSInteger)kindergarten
                                         withSender:(CBLoginInfo*)senderInfo
                                        withClassId:(NSNumber*)classId
                                        withContent:(NSString*)content
                                          withTitle:(NSString*)title
                                   withImageUrlList:(NSArray*)imgUrlList
                                           withTags:(NSArray*)tags
                               withRequriedFeedback:(BOOL)requriedFeedback
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opPostAssignmentOfKindergarten:(NSInteger)kindergarten
                                               withSender:(CBLoginInfo*)senderInfo
                                              withClassId:(NSNumber*)classId
                                              withContent:(NSString*)content
                                                withTitle:(NSString*)title
                                         withImageUrlList:(NSArray*)imgUrlList
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opCheckUpdates:(NSString*)appId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetTopicMsgsOfChild:(NSString*)childId
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(long long)fromId
                                              to:(long long)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opDeleteTopicMsgs:(long long)msgId
                                     ofChild:(NSString*)childId
                              inKindergarten:(NSInteger)kindergarten
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opSendTopicMsg:(NSString*)msgBody
                               withSender:(CBLoginInfo*)senderInfo
                             withMediaUrl:(NSString*)mediaUrl
                              ofMediaType:(NSString*)mediaType
                                  ofChild:(NSString*)childId
                           inKindergarten:(NSInteger)kindergarten
                             retrieveFrom:(long long)fromId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetTopicMsgSender:(NSString*)senderId
                                        ofType:(NSString*)senderType
                                inKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opSendAssessment:(NSArray*)assessmentList
                             inKindergarten:(NSInteger)kindergarten
                                 fromSender:(NSString*)sender
                               withSenderId:(NSString*)senderId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opUpdateProfile:(NSDictionary*)newProfile
                                  ofSender:(CBLoginInfo*)loginInfo
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetAssessmentsOfChild:(NSString*)childId
                                    inKindergarten:(NSInteger)kindergarten
                                              from:(long long)fromId
                                                to:(long long)toId
                                              most:(NSInteger)most
                                           success:(SuccessResponseHandler)success
                                           failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opResetPswdOfAccount:(NSString*)accountName
                                    withNewPswd:(NSString*)newPswd
                                    andAuthCode:(NSString*)authCode
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetSmsCode:(NSString*)phone
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetNewsReaders:(NSNumber*)newsId
                             inKindergarten:(NSInteger)schoolId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opDeleteNews:(NSNumber*)newsId
                         inKindergarten:(NSInteger)schoolId
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)opGetIneligibleClassOfKindergarten:(NSInteger)kindergarten
                                                 withSenderId:(NSString*)senderId
                                                      success:(SuccessResponseHandler)success
                                                      failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetClassesOfKindergarten:(NSInteger)kindergarten
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;


- (NSURLSessionDataTask*)reqGetTeachersOfKindergarten:(NSInteger)kindergarten
                                            withClassId:(NSInteger)classId
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetRelationshipsOfKindergarten:(NSInteger)kindergarten
                                                 withClassId:(NSInteger)classId
                                                     success:(SuccessResponseHandler)success
                                                     failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetBandListOfKindergarten:(NSInteger)kindergarten
                                            withClassId:(NSInteger)classId
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqAddBandUser:(NSString*)imUser
                           inKindergarten:(NSInteger)kindergarten
                              withClassId:(NSInteger)classId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqDeleteBandUser:(NSString*)imUser
                              inKindergarten:(NSInteger)kindergarten
                                 withClassId:(NSInteger)classId
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetiIneligibleClass:(NSInteger)employeeId
                                   inKindergarten:(NSInteger)kindergarten
                                          success:(SuccessResponseHandler)success
                                          failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqIMJoinGroupOfKindergarten:(NSInteger)kindergarten
                                            withClassId:(NSInteger)classId
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetHistoryList:(NSString*)employeeId
                              inKindergarten:(NSInteger)kindergarten
                                        from:(NSNumber*)from
                                          to:(NSNumber*)to
                                        most:(NSNumber*)most
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetConfigOfKindergarten:(NSInteger)kindergarten
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure;


@end

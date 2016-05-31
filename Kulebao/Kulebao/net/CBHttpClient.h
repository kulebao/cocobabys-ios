//
//  CBHttpClient.h
//  youlebao
//
//  Created by WangXin on 11/8/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "CSKuleServerUrls.h"
#import "CSKuleParentInfo.h"
#import "CSKuleChildInfo.h"
#import "CSKuleSenderInfo.h"
#import "CSKuleNewsInfo.h"
#import "CBActivityData.h"

typedef void (^SuccessResponseHandler) (NSURLSessionDataTask *task, id dataJson);
typedef void (^FailureResponseHandler) (NSURLSessionDataTask *task, NSError *error);

@interface CBHttpClient : NSObject
+ (instancetype)sharedInstance;

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path;

#pragma mark - Uploader
- (NSURLSessionDataTask*)reqUploadToQiniu:(NSData*)data
                                    withKey:(NSString*)key
                                   withMime:(NSString*)mime
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

#pragma mark - Check update on iTunes
- (NSURLSessionDataTask*)reqCheckITunesUpdates:(NSString*)appId
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure;

#pragma mark - HTTP Request
- (NSURLSessionDataTask*)reqCheckPhoneNum:(NSString*)mobile
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqLogin:(NSString*)mobile
                           withPswd:(NSString*)password
                            success:(SuccessResponseHandler)success
                            failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqReceiveBindInfo:(NSString*)mobile
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqUnbindWithSuccess:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqChangePassword:(NSString*)newPswd
                                 withOldPswd:(NSString*)oldPswd
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetFamilyRelationship:(NSString*)mobile
                                     inKindergarten:(NSInteger)kindergarten
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetChildRelationship:(NSString*)childId
                                    inKindergarten:(NSInteger)kindergarten
                                           success:(SuccessResponseHandler)success
                                           failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqUpdateChildInfo:(CSKuleChildInfo*)childInfo
                               inKindergarten:(NSInteger)kindergarten
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqUpdateParentInfo:(CSKuleParentInfo*)parentInfo
                                inKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetNewsOfKindergarten:(NSInteger)kindergarten
                                        withClassId:(NSInteger)classId
                                               from:(NSInteger)fromId
                                                 to:(NSInteger)toId
                                               most:(NSInteger)most
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetCookbooksOfKindergarten:(NSInteger)kindergarten
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetAssignmentsOfKindergarten:(NSInteger)kindergarten
                                               withClassId:(NSInteger)classId
                                                      from:(NSInteger)fromId
                                                        to:(NSInteger)toId
                                                      most:(NSInteger)most
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetSchedulesOfKindergarten:(NSInteger)kindergarten
                                             withClassId:(NSInteger)classId
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetSchoolInfoOfKindergarten:(NSInteger)kindergarten
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetCheckInOutLogOfChild:(CSKuleChildInfo*)childInfo
                                       inKindergarten:(NSInteger)kindergarten
                                                 from:(NSTimeInterval)fromTimestamp
                                                   to:(NSTimeInterval)toTimestamp
                                                 most:(NSInteger)most
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqSendChatingMsg:(NSString*)msgBody
                                   withImage:(NSString*)imgUrl
                              toKindergarten:(NSInteger)kindergarten
                                retrieveFrom:(long long)fromId
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                                    from:(long long)fromId
                                                      to:(long long)toId
                                                    most:(NSInteger)most
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqDeleteTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                                   recordId:(long long)msgId
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqSendTopicMsg:(NSString*)msgBody
                              withMediaUrl:(NSString*)mediaUrl
                               ofMediaType:(NSString*)mediaType
                            toKindergarten:(NSInteger)kindergarten
                              retrieveFrom:(long long)fromId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetAssessesOfChild:(CSKuleChildInfo*)childInfo
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(NSInteger)fromId
                                              to:(NSInteger)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetSmsCode:(NSString*)phone
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqBindPhone:(NSString*)phone
                                smsCode:(NSString*)authcode
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqResetPswd:(NSString*)account
                                smsCode:(NSString*)authcode
                            withNewPswd:(NSString*)newPswd
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqSendFeedback:(NSString*)account
                               withContent:(NSString*)msgContent
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetEmployeeListOfKindergarten:(NSInteger)kindergarten
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetSenderProfileOfKindergarten:(NSInteger)kindergarten
                                                  withSender:(CSKuleSenderInfo*)senderInfo
                                                    complete:(void (^)(id obj))complete;

- (NSURLSessionDataTask*)reqGetHistoryListOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                  fromDate:(NSDate*)fromDate
                                                    toDate:(NSDate*)toDate
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqPostHistoryOfKindergarten:(NSInteger)kindergarten
                                            withChildId:(NSString*)childId
                                            withContent:(NSString*)content
                                       withImageUrlList:(NSArray*)imgUrlList
                                           withVideoUrl:(NSString*)videoUrl
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqDeleteHistoryOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                                 recordId:(long long)msgId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetVideoMemberListOfKindergarten:(NSInteger)kindergarten
                                                       success:(SuccessResponseHandler)success
                                                       failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetVideoMemberOfKindergarten:(NSInteger)kindergarten
                                              withParentId:(NSString*)parentId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetDefaultVideoMemberOfKindergarten:(NSInteger)kindergarten
                                                          success:(SuccessResponseHandler)success
                                                          failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqMarkAsRead:(CSKuleNewsInfo*)newsInfo
                                byParent:(CSKuleParentInfo*)parentInfo
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqQueryReadStatusOf:(CSKuleNewsInfo*)newsInfo
                                       byParent:(CSKuleParentInfo*)parentInfo
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetBusLocationOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetShareTokenOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                             withRecordId:(NSInteger)recordId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetActivityListOfKindergarten:(NSInteger)kindergarten
                                                       from:(long long)fromId
                                                         to:(long long)toId
                                                       most:(NSInteger)most
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetContractorListOfKindergarten:(NSInteger)kindergarten
                                                 withCategory:(NSInteger)category
                                                         from:(long long)fromId
                                                           to:(long long)toId
                                                         most:(NSInteger)most
                                                      success:(SuccessResponseHandler)success
                                                      failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetActivityListOfKindergarten:(NSInteger)kindergarten
                                           withContractorId:(NSInteger)contractorId
                                                       from:(long long)fromId
                                                         to:(long long)toId
                                                       most:(NSInteger)most
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetEnrollmentOfKindergarten:(NSInteger)kindergarten
                                             withActivity:(NSInteger)activityId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqPostEnrollmentOfKindergarten:(NSInteger)kindergarten
                                              withActivity:(CBActivityData*)activity
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetInviteCodeWithHost:(NSString*)hostPhone
                                         andInvitee:(NSString*)smsPhone
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqBindCardOfKindergarten:(NSInteger)kindergarten
                                         withCardNum:(NSString*)cardNum
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqCreateInvitationOfKindergarten:(NSInteger)kindergarten
                                                       phone:(NSString*)phone
                                                        name:(NSString*)name
                                                relationship:(NSString*)relationship
                                                    passcode:(NSString*)passcode
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

- (NSURLSessionDataTask*)reqUpdateCard:(NSString*)cardNum
                        withRelationship:(NSString*)relationship
                          inKindergarten:(NSInteger)kindergarten
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqIMJoinGroupOfKindergarten:(NSInteger)kindergarten
                                            withClassId:(NSInteger)classId
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqIMQuitGroupOfKindergarten:(NSInteger)kindergarten
                                          withClassId:(NSInteger)classId
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetConfigOfKindergarten:(NSInteger)kindergarten
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqGetIMBandInfoOfKindergarten:(NSInteger)kindergarten
                                            withClassId:(NSInteger)classId
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqHideGroupMsgs:(NSArray*)msgUids
                           inKindergarten:(NSInteger)kindergarten
                              withClassId:(NSInteger)classId
                                  success:(SuccessResponseHandler)success
                                  failure:(FailureResponseHandler)failure;

- (NSURLSessionDataTask*)reqHidePrivateMsgs:(NSArray*)msgUids
                             inKindergarten:(NSInteger)kindergarten
                               withTargetId:(NSString*)targetId
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

@end

//
//  CBHttpClient.h
//  youlebao
//
//  Created by WangXin on 11/8/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "AFJSONRequestOperation+CSKit.h"
#import "CSKuleServerUrls.h"
#import "CSKuleParentInfo.h"
#import "CSKuleChildInfo.h"
#import "CSKuleSenderInfo.h"
#import "CSKuleNewsInfo.h"
#import "CBActivityData.h"

typedef void (^SuccessResponseHandler) (AFHTTPRequestOperation *operation, id dataJson);
typedef void (^FailureResponseHandler) (AFHTTPRequestOperation *operation, NSError *error);

@interface CBHttpClient : NSObject
+ (instancetype)sharedInstance;

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path;

#pragma mark - Uploader
- (AFHTTPRequestOperation*)reqUploadToQiniu:(NSData*)data
                                    withKey:(NSString*)key
                                   withMime:(NSString*)mime
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

#pragma mark - Check update on iTunes
- (AFHTTPRequestOperation*)reqCheckITunesUpdates:(NSString*)appId
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure;

#pragma mark - HTTP Request
- (AFHTTPRequestOperation*)reqCheckPhoneNum:(NSString*)mobile
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqLogin:(NSString*)mobile
                           withPswd:(NSString*)password
                            success:(SuccessResponseHandler)success
                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqReceiveBindInfo:(NSString*)mobile
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqUnbindWithSuccess:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqChangePassword:(NSString*)newPswd
                                 withOldPswd:(NSString*)oldPswd
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetFamilyRelationship:(NSString*)mobile
                                     inKindergarten:(NSInteger)kindergarten
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetChildRelationship:(NSString*)childId
                                    inKindergarten:(NSInteger)kindergarten
                                           success:(SuccessResponseHandler)success
                                           failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqUpdateChildInfo:(CSKuleChildInfo*)childInfo
                               inKindergarten:(NSInteger)kindergarten
                                      success:(SuccessResponseHandler)success
                                      failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqUpdateParentInfo:(CSKuleParentInfo*)parentInfo
                                inKindergarten:(NSInteger)kindergarten
                                       success:(SuccessResponseHandler)success
                                       failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetNewsOfKindergarten:(NSInteger)kindergarten
                                        withClassId:(NSInteger)classId
                                               from:(NSInteger)fromId
                                                 to:(NSInteger)toId
                                               most:(NSInteger)most
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetCookbooksOfKindergarten:(NSInteger)kindergarten
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetAssignmentsOfKindergarten:(NSInteger)kindergarten
                                               withClassId:(NSInteger)classId
                                                      from:(NSInteger)fromId
                                                        to:(NSInteger)toId
                                                      most:(NSInteger)most
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetSchedulesOfKindergarten:(NSInteger)kindergarten
                                             withClassId:(NSInteger)classId
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetSchoolInfoOfKindergarten:(NSInteger)kindergarten
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetCheckInOutLogOfChild:(CSKuleChildInfo*)childInfo
                                       inKindergarten:(NSInteger)kindergarten
                                                 from:(NSTimeInterval)fromTimestamp
                                                   to:(NSTimeInterval)toTimestamp
                                                 most:(NSInteger)most
                                              success:(SuccessResponseHandler)success
                                              failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqSendChatingMsg:(NSString*)msgBody
                                   withImage:(NSString*)imgUrl
                              toKindergarten:(NSInteger)kindergarten
                                retrieveFrom:(long long)fromId
                                     success:(SuccessResponseHandler)success
                                     failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                                    from:(long long)fromId
                                                      to:(long long)toId
                                                    most:(NSInteger)most
                                                 success:(SuccessResponseHandler)success
                                                 failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqDeleteTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                                   recordId:(long long)msgId
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqSendTopicMsg:(NSString*)msgBody
                              withMediaUrl:(NSString*)mediaUrl
                               ofMediaType:(NSString*)mediaType
                            toKindergarten:(NSInteger)kindergarten
                              retrieveFrom:(long long)fromId
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetAssessesOfChild:(CSKuleChildInfo*)childInfo
                                  inKindergarten:(NSInteger)kindergarten
                                            from:(NSInteger)fromId
                                              to:(NSInteger)toId
                                            most:(NSInteger)most
                                         success:(SuccessResponseHandler)success
                                         failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetSmsCode:(NSString*)phone
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqBindPhone:(NSString*)phone
                                smsCode:(NSString*)authcode
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqResetPswd:(NSString*)account
                                smsCode:(NSString*)authcode
                            withNewPswd:(NSString*)newPswd
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqSendFeedback:(NSString*)account
                               withContent:(NSString*)msgContent
                                   success:(SuccessResponseHandler)success
                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetEmployeeListOfKindergarten:(NSInteger)kindergarten
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetSenderProfileOfKindergarten:(NSInteger)kindergarten
                                                  withSender:(CSKuleSenderInfo*)senderInfo
                                                    complete:(void (^)(id obj))complete;

- (AFHTTPRequestOperation*)reqGetHistoryListOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                  fromDate:(NSDate*)fromDate
                                                    toDate:(NSDate*)toDate
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqPostHistoryOfKindergarten:(NSInteger)kindergarten
                                            withChildId:(NSString*)childId
                                            withContent:(NSString*)content
                                       withImageUrlList:(NSArray*)imgUrlList
                                           withVideoUrl:(NSString*)videoUrl
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqDeleteHistoryOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                                 recordId:(long long)msgId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetVideoMemberListOfKindergarten:(NSInteger)kindergarten
                                                       success:(SuccessResponseHandler)success
                                                       failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetVideoMemberOfKindergarten:(NSInteger)kindergarten
                                              withParentId:(NSString*)parentId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetDefaultVideoMemberOfKindergarten:(NSInteger)kindergarten
                                                          success:(SuccessResponseHandler)success
                                                          failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqMarkAsRead:(CSKuleNewsInfo*)newsInfo
                                byParent:(CSKuleParentInfo*)parentInfo
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqQueryReadStatusOf:(CSKuleNewsInfo*)newsInfo
                                       byParent:(CSKuleParentInfo*)parentInfo
                                        success:(SuccessResponseHandler)success
                                        failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetBusLocationOfKindergarten:(NSInteger)kindergarten
                                               withChildId:(NSString*)childId
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetShareTokenOfKindergarten:(NSInteger)kindergarten
                                              withChildId:(NSString*)childId
                                             withRecordId:(NSInteger)recordId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetActivityListOfKindergarten:(NSInteger)kindergarten
                                                       from:(long long)fromId
                                                         to:(long long)toId
                                                       most:(NSInteger)most
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetContractorListOfKindergarten:(NSInteger)kindergarten
                                                 withCategory:(NSInteger)category
                                                         from:(long long)fromId
                                                           to:(long long)toId
                                                         most:(NSInteger)most
                                                      success:(SuccessResponseHandler)success
                                                      failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetActivityListOfKindergarten:(NSInteger)kindergarten
                                           withContractorId:(NSInteger)contractorId
                                                       from:(long long)fromId
                                                         to:(long long)toId
                                                       most:(NSInteger)most
                                                    success:(SuccessResponseHandler)success
                                                    failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetEnrollmentOfKindergarten:(NSInteger)kindergarten
                                             withActivity:(NSInteger)activityId
                                                  success:(SuccessResponseHandler)success
                                                  failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqPostEnrollmentOfKindergarten:(NSInteger)kindergarten
                                              withActivity:(CBActivityData*)activity
                                                   success:(SuccessResponseHandler)success
                                                   failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetInviteCodeWithHost:(NSString*)hostPhone
                                         andInvitee:(NSString*)smsPhone
                                            success:(SuccessResponseHandler)success
                                            failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqBindCardOfKindergarten:(NSInteger)kindergarten
                                         withCardNum:(NSString*)cardNum
                                             success:(SuccessResponseHandler)success
                                             failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqCreateInvitationOfKindergarten:(NSInteger)kindergarten
                                                       phone:(NSString*)phone
                                                        name:(NSString*)name
                                                relationship:(NSString*)relationship
                                                    passcode:(NSString*)passcode
                                                     success:(SuccessResponseHandler)success
                                                     failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetClassesOfKindergarten:(NSInteger)kindergarten
                                               success:(SuccessResponseHandler)success
                                               failure:(FailureResponseHandler)failure;


- (AFHTTPRequestOperation*)reqGetTeachersOfKindergarten:(NSInteger)kindergarten
                                            withClassId:(NSInteger)classId
                                                success:(SuccessResponseHandler)success
                                                failure:(FailureResponseHandler)failure;

- (AFHTTPRequestOperation*)reqGetRelationshipsOfKindergarten:(NSInteger)kindergarten
                                                 withClassId:(NSInteger)classId
                                                     success:(SuccessResponseHandler)success
                                                     failure:(FailureResponseHandler)failure;

@end

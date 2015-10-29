//
//  CSKuleEngine.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-3.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CSHttpClient.h"
#import "CSKuleCommon.h"
#import "CSKuleServerUrls.h"
#import "CSKulePreferences.h"
#import "CSKuleInterpreter.h"
#import "hm_sdk.h"
#import "CBActivityData.h"

@interface CSKuleEngine : NSObject
@property (strong, nonatomic) CSKulePreferences* preferences;
@property (strong, nonatomic) CSKuleLoginInfo* loginInfo;

@property (strong, nonatomic) NSArray* relationships;
@property (strong, nonatomic) CSKuleRelationshipInfo* currentRelationship;

@property (strong, nonatomic, readonly) UIApplication* application;

@property (nonatomic, assign) NSInteger badgeOfNews;
@property (nonatomic, assign) NSInteger badgeOfRecipe;
@property (nonatomic, assign) NSInteger badgeOfCheckin;
@property (nonatomic, assign) NSInteger badgeOfSchedule;
@property (nonatomic, assign) NSInteger badgeOfAssignment;
@property (nonatomic, assign) NSInteger badgeOfChating;
@property (nonatomic, assign) NSInteger badgeOfAssess;

@property (nonatomic, assign) server_id hmServerId;

@property (nonatomic, strong) BMKLocationService* locService;

// For test only
@property (nonatomic, strong, readonly) NSMutableArray* receivedNotifications;
@property (nonatomic, strong) NSData* deviceToken;
@property (nonatomic, strong) NSDictionary* pendingNotificationInfo;


#pragma mark - application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - Setup
- (void)setupEngine;

#pragma mark - URL
- (NSURL*)urlFromPath:(NSString*)path;

#pragma mark - Core Data
// 初始化Core Data使用的数据库
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

// managedObjectModel的初始化赋值函数
-(NSManagedObjectModel *)managedObjectModel;

// managedObjectContext的初始化赋值函数
-(NSManagedObjectContext *)managedObjectContext;

#pragma mark - Uploader
- (void)reqUploadToQiniu:(NSData*)data
                 withKey:(NSString*)key
                withMime:(NSString*)mime
                 success:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure;

#pragma mark - Retry
- (void)retryRequestOperationAfterBind:(AFHTTPRequestOperation*)operation;

#pragma mark - Check Updates
- (void)checkUpdatesOfNews;
- (void)checkUpdatesOfRecipe;
- (void)checkUpdatesOfCheckin;
- (void)checkUpdatesOfSchedule;
- (void)checkUpdatesOfAssignment;
- (void)checkUpdatesOfChating;
- (void)checkUpdatesOfAssess;

#pragma mark - HTTP Request
- (void)reqCheckPhoneNum:(NSString*)mobile
                 success:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure;

- (void)reqLogin:(NSString*)mobile
        withPswd:(NSString*)password
         success:(SuccessResponseHandler)success
         failure:(FailureResponseHandler)failure;

- (void)reqReceiveBindInfo:(NSString*)mobile
                   success:(SuccessResponseHandler)success
                   failure:(FailureResponseHandler)failure;

- (void)reqUnbindWithSuccess:(SuccessResponseHandler)success
                 failure:(FailureResponseHandler)failure;

- (void)reqChangePassword:(NSString*)newPswd
              withOldPswd:(NSString*)oldPswd
                  success:(SuccessResponseHandler)success
                  failure:(FailureResponseHandler)failure;

- (void)reqGetFamilyRelationship:(NSString*)mobile
                      inKindergarten:(NSInteger)kindergarten
                             success:(SuccessResponseHandler)success
                             failure:(FailureResponseHandler)failure;

- (void)reqGetChildRelationship:(NSString*)childId
                 inKindergarten:(NSInteger)kindergarten
                        success:(SuccessResponseHandler)success
                        failure:(FailureResponseHandler)failure;

- (void)reqUpdateChildInfo:(CSKuleChildInfo*)childInfo
            inKindergarten:(NSInteger)kindergarten
                   success:(SuccessResponseHandler)success
                   failure:(FailureResponseHandler)failure;

- (void)reqUpdateParentInfo:(CSKuleParentInfo*)parentInfo
             inKindergarten:(NSInteger)kindergarten
                    success:(SuccessResponseHandler)success
                    failure:(FailureResponseHandler)failure;

- (void)reqGetNewsOfKindergarten:(NSInteger)kindergarten
                     withClassId:(NSInteger)classId
                            from:(NSInteger)fromId
                              to:(NSInteger)toId
                            most:(NSInteger)most
                         success:(SuccessResponseHandler)success
                         failure:(FailureResponseHandler)failure;

- (void)reqGetCookbooksOfKindergarten:(NSInteger)kindergarten
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure;

- (void)reqGetAssignmentsOfKindergarten:(NSInteger)kindergarten
                            withClassId:(NSInteger)classId
                                   from:(NSInteger)fromId
                                     to:(NSInteger)toId
                                   most:(NSInteger)most
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (void)reqGetSchedulesOfKindergarten:(NSInteger)kindergarten
                          withClassId:(NSInteger)classId
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure;

- (void)reqGetSchoolInfoOfKindergarten:(NSInteger)kindergarten
                               success:(SuccessResponseHandler)success
                               failure:(FailureResponseHandler)failure;

- (void)reqGetCheckInOutLogOfChild:(CSKuleChildInfo*)childInfo
                    inKindergarten:(NSInteger)kindergarten
                              from:(NSTimeInterval)fromTimestamp
                                to:(NSTimeInterval)toTimestamp
                              most:(NSInteger)most
                           success:(SuccessResponseHandler)success
                           failure:(FailureResponseHandler)failure;

//- (void)reqGetChatingMsgsOfKindergarten:(NSInteger)kindergarten
//                                   from:(long long)fromId
//                                     to:(long long)toId
//                                   most:(NSInteger)most
//                                success:(SuccessResponseHandler)success
//                                failure:(FailureResponseHandler)failure;

- (void)reqSendChatingMsg:(NSString*)msgBody
                withImage:(NSString*)imgUrl
           toKindergarten:(NSInteger)kindergarten
             retrieveFrom:(long long)fromId
                  success:(SuccessResponseHandler)success
                  failure:(FailureResponseHandler)failure;

- (void)reqGetTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                 from:(long long)fromId
                                   to:(long long)toId
                                 most:(NSInteger)most
                              success:(SuccessResponseHandler)success
                              failure:(FailureResponseHandler)failure;

- (void)reqDeleteTopicMsgsOfKindergarten:(NSInteger)kindergarten
                                recordId:(long long)msgId
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (void)reqSendTopicMsg:(NSString*)msgBody
           withMediaUrl:(NSString*)mediaUrl
            ofMediaType:(NSString*)mediaType
         toKindergarten:(NSInteger)kindergarten
           retrieveFrom:(long long)fromId
                success:(SuccessResponseHandler)success
                failure:(FailureResponseHandler)failure;

- (void)reqGetAssessesOfChild:(CSKuleChildInfo*)childInfo
               inKindergarten:(NSInteger)kindergarten
                         from:(NSInteger)fromId
                           to:(NSInteger)toId
                         most:(NSInteger)most
                      success:(SuccessResponseHandler)success
                      failure:(FailureResponseHandler)failure;

- (void)reqGetSmsCode:(NSString*)phone
              success:(SuccessResponseHandler)success
              failure:(FailureResponseHandler)failure;

- (void)reqBindPhone:(NSString*)phone
             smsCode:(NSString*)authcode
             success:(SuccessResponseHandler)success
             failure:(FailureResponseHandler)failure;

- (void)reqResetPswd:(NSString*)account
             smsCode:(NSString*)authcode
         withNewPswd:(NSString*)newPswd
             success:(SuccessResponseHandler)success
             failure:(FailureResponseHandler)failure;

- (void)reqSendFeedback:(NSString*)account
            withContent:(NSString*)msgContent
                success:(SuccessResponseHandler)success
                failure:(FailureResponseHandler)failure;

- (void)reqGetEmployeeListOfKindergarten:(NSInteger)kindergarten
                                 success:(SuccessResponseHandler)success
                                 failure:(FailureResponseHandler)failure;

- (void)reqGetSenderProfileOfKindergarten:(NSInteger)kindergarten
                               withSender:(CSKuleSenderInfo*)senderInfo
                                 complete:(void (^)(id obj))complete;

- (void)reqGetHistoryListOfKindergarten:(NSInteger)kindergarten
                            withChildId:(NSString*)childId
                               fromDate:(NSDate*)fromDate
                                 toDate:(NSDate*)toDate
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (void)reqPostHistoryOfKindergarten:(NSInteger)kindergarten
                         withChildId:(NSString*)childId
                         withContent:(NSString*)content
                    withImageUrlList:(NSArray*)imgUrlList
                        withVideoUrl:(NSString*)videoUrl
                             success:(SuccessResponseHandler)success
                             failure:(FailureResponseHandler)failure;

- (void)reqDeleteHistoryOfKindergarten:(NSInteger)kindergarten
                           withChildId:(NSString*)childId
                              recordId:(long long)msgId
                               success:(SuccessResponseHandler)success
                               failure:(FailureResponseHandler)failure;

- (void)reqGetVideoMemberListOfKindergarten:(NSInteger)kindergarten
                                    success:(SuccessResponseHandler)success
                                    failure:(FailureResponseHandler)failure;

- (void)reqGetVideoMemberOfKindergarten:(NSInteger)kindergarten
                           withParentId:(NSString*)parentId
                                success:(SuccessResponseHandler)success
                                failure:(FailureResponseHandler)failure;

- (void)reqGetDefaultVideoMemberOfKindergarten:(NSInteger)kindergarten
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

@end

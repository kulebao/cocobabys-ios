//
//  CSHttpClient.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-15.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface CSHttpClient : NSObject

+ (id)sharedInstance;

- (AFHTTPRequestOperation*)opLoginWithUsername:(NSString*)username
                                      password:(NSString*)password
                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation*)opGetClassListOfKindergarten:(NSInteger)schoolId
                                         withEmployeeId:(NSString*)employeePhone
                                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation*)opGetChildListOfKindergarten:(NSInteger)schoolId
                                          withClassList:(NSArray*)classIdList
                                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation*)opGetDailylogOfKindergarten:(NSInteger)schoolId
                                         withClassList:(NSArray*)classIdList
                                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation*)opGetRelationshipOfChild:(NSString*)childId
                                     inKindergarten:(NSInteger)schoolId
                                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation*)opGetNewsOfClasses:(NSArray*)classIdList
                               inKindergarten:(NSInteger)schoolId
                                         from:(NSNumber*)from
                                           to:(NSNumber*)to
                                         most:(NSNumber*)most
                                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation*)opGetAssignmentsOfClasses:(NSArray*)classIdList
                                      inKindergarten:(NSInteger)schoolId
                                                from:(NSNumber*)from
                                                  to:(NSNumber*)to
                                                most:(NSNumber*)most
                                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

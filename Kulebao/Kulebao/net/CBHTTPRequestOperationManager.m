//
//  CBHTTPRequestOperationManager.m
//  youlebao
//
//  Created by WangXin on 11/8/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBHTTPRequestOperationManager.h"
#import "CSAppDelegate.h"

@implementation CBHTTPRequestOperationManager
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;
{
    return [super dataTaskWithRequest:request
                    completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
                        NSHTTPURLResponse* resp = (NSHTTPURLResponse*)response;
                        if (resp.statusCode == 401) {
                            [gApp gotoLoginProcess];
                            [gApp alert:@"会话已经过期，请重新登录。"];
                        }
                        else if (completionHandler) {
                            completionHandler(response, responseObject, error);
                        }
    }];
}

//- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
//                                                    success:(nullable void (^)(NSURLSessionDataTask *task, id responseObject))success
//                                                    failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure {
//    
//    return [super dataTaskWithRequest:request
//                                          success:^(NSURLSessionDataTask * _Nonnull operation, id  _Nonnull responseObject) {
//                                              if(success) success(operation, responseObject);
//                                          } failure:^(NSURLSessionDataTask * _Nonnull operation, NSError * _Nonnull error) {
//                                              
//                                              if (operation.response.statusCode == 401) {
//                                                  [gApp gotoLoginProcess];
//                                                  [gApp alert:@"会话已经过期，请重新登录。"];
//                                              }
//                                              else if (failure) {
//                                                  failure(operation, error);
//                                              }
//                                              
//                                          }];
//}

@end

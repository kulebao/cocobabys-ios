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

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [super HTTPRequestOperationWithRequest:request
                                          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                              if(success) success(operation, responseObject);
                                          } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                              
                                              if (operation.response.statusCode == 401) {
                                                  [gApp gotoLoginProcess];
                                                  [gApp alert:@"会话已经过期，请重新登录。"];
                                              }
                                              else if (failure) {
                                                  failure(operation, error);
                                              }
                                              
                                          }];
}

@end

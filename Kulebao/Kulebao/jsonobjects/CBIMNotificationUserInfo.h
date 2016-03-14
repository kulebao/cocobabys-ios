//
//  CBIMNotificationUserInfo.h
//  youlebao
//
//  Created by WangXin on 2/18/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBIMNotificationUserInfo : CSJsonObject

@property (nonatomic, strong) NSString* cType;
@property (nonatomic, strong) NSString* fId;
@property (nonatomic, strong) NSString* oName;
@property (nonatomic, strong) NSString* tId;

@end

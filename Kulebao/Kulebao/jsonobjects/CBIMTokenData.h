//
//  CBIMTokenData.h
//  youlebao
//
//  Created by WangXin on 12/3/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBIMTokenData : CSJsonObject

@property (nonatomic, strong) NSString* source;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* user_id;

@end

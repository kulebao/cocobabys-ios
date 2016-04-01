//
//  CBIMInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBIMInfo : CSJsonObject

@property (nonatomic, strong) NSString* source;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* user_id;

@end

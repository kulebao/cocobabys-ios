//
//  CBClassInfo.h
//  youlebao
//
//  Created by WangXin on 12/7/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBClassInfo : CSJsonObject

@property (nonatomic, assign) NSInteger school_id;
@property (nonatomic, assign) NSInteger class_id;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSNumber* updated_at;
@property (nonatomic, assign) NSInteger status;

@end

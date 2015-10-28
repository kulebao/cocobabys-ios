//
//  CSKuleRelationshipInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-5.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKuleChildInfo.h"
#import "CSKuleParentInfo.h"

@interface CSKuleRelationshipInfo : NSObject

@property (nonatomic, strong) CSKuleParentInfo* parent;
@property (nonatomic, strong) CSKuleChildInfo* child;
@property (nonatomic, strong) NSString* card;
@property (nonatomic, strong) NSString* relationship;
@property (nonatomic, assign) NSInteger uid;

@end

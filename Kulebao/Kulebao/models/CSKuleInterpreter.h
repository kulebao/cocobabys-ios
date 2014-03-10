//
//  CSKuleInterpreter.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSKuleRelationshipInfo.h"
#import "CSKuleLoginInfo.h"
#import "CSKuleBindInfo.h"
#import "CSKuleNewsInfo.h"
#import "CSKuleCookbookInfo.h"

@interface CSKuleInterpreter : NSObject

+ (CSKuleLoginInfo*)decodeLoginInfo:(NSDictionary*)dataJson;

+ (CSKuleBindInfo*)decodeBindInfo:(NSDictionary*)dataJson;

+ (CSKuleRelationshipInfo*)decodeRelationshipInfo:(NSDictionary*)dataJson;

+ (CSKuleChildInfo*)decodeChildInfo:(NSDictionary*)dataJson;

+ (CSKuleParentInfo*)decodeParentInfo:(NSDictionary*)dataJson;

+ (CSKuleNewsInfo*)decodeNewsInfo:(NSDictionary*)dataJson;

+ (CSKuleCookbookInfo*)decodeCookbookInfo:(NSDictionary*)dataJson;

+ (CSKuleRecipeInfo*)decodeRecipeInfo:(NSDictionary*)dataJson;

@end

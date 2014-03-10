//
//  CSKuleCookbookInfo.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKuleRecipeInfo.h"

@interface CSKuleCookbookInfo : NSObject

@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, assign) NSInteger schoolId;
@property (nonatomic, assign) NSInteger cookbookId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSString* extraTip;

@property (nonatomic, strong) CSKuleRecipeInfo* mon;
@property (nonatomic, strong) CSKuleRecipeInfo* tue;
@property (nonatomic, strong) CSKuleRecipeInfo* wed;
@property (nonatomic, strong) CSKuleRecipeInfo* thu;
@property (nonatomic, strong) CSKuleRecipeInfo* fri;

@end

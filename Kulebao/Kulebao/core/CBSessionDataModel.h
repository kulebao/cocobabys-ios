//
//  CBSessionDataModel.h
//  youlebao
//
//  Created by WangXin on 2/17/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBSessionDataModel : NSObject<NSCoding>

@property (nonatomic, readonly, strong) NSString* username;
@property (nonatomic, readonly, strong) NSString* tag;

@property (nonatomic, readonly, strong) NSMutableSet* imGroupTags;

+ (instancetype)session:(NSString*)username;
+ (instancetype)session:(NSString*)username withTag:(NSString*)tag;
+ (instancetype)thisSession;

- (void)invalidate;
- (void)store;

@end

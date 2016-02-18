//
//  CBIMSettingsModel.h
//  youlebao
//
//  Created by WangXin on 1/6/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBIMSettingsModel : NSObject<NSCoding>

+ (instancetype)sharedInstance;

- (void)setGroup:(NSString*)targetId disturb:(BOOL)enabled;
- (BOOL)getGroupDistrubEnabled:(NSString*)targetId;

@end

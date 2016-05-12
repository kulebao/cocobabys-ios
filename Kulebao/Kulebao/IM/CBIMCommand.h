//
//  CBIMCommand.h
//  youlebao
//
//  Created by WangXin on 5/12/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBIMCommand : NSObject

@property (nonatomic, strong) NSString* cmd;
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSNumber* schoolId;
@property (nonatomic, strong) NSNumber* classId;

- (BOOL)parse:(NSString*)cmdline;

@end

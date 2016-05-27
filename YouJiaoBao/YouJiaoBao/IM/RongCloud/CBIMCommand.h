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
@property (nonatomic, strong) NSArray* params;

// ban, approval
@property (nonatomic, strong, readonly) NSString* userId;
@property (nonatomic, strong, readonly) NSNumber* schoolId;
@property (nonatomic, strong, readonly) NSNumber* classId;

// hidemsg
@property (nonatomic, strong, readonly) NSString* subtype;
@property (nonatomic, strong, readonly) NSString* msgUid;
//@property (nonatomic, strong, readonly) NSNumber* schoolId;
//@property (nonatomic, strong, readonly) NSNumber* classId;

- (BOOL)parse:(NSString*)cmdline;

@end

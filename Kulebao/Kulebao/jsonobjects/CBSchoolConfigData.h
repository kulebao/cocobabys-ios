//
//  CBSchoolConfigData.h
//  youlebao
//
//  Created by WangXin on 3/11/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBConfigData : CSJsonObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, strong) NSString* category;

@end

@interface CBSchoolConfigData : CSJsonObject

@property (nonatomic, assign) NSInteger school_id;
@property (nonatomic, strong) NSArray* config;
@property (nonatomic, assign) NSArray* school_customized;

@property (nonatomic, assign, readonly) BOOL enableHealthRecordManagement;
@property (nonatomic, assign, readonly) BOOL enableFinancialManagement;
@property (nonatomic, assign, readonly) BOOL enableWarehouseManagement;
@property (nonatomic, assign, readonly) BOOL enableDietManagement;
@property (nonatomic, assign, readonly) BOOL schoolGroupChat;

@end

//
//  EntityLoginInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 1/17/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface EntityLoginInfo : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@property (nonatomic, strong) NSArray* ineligibleClassList;
@property (nonatomic, assign, readonly) BOOL allowToSendAll;

@end

NS_ASSUME_NONNULL_END

#import "EntityLoginInfo+CoreDataProperties.h"

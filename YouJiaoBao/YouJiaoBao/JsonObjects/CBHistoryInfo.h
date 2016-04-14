//
//  CBHistoryInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 3/8/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"
#import "CBSenderInfo.h"
#import "CBMediaInfo.h"

@interface CBHistoryInfo : CSJsonObject

@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSString* topic;
@property (nonatomic, strong) NSNumber* timestamp;

@property (nonatomic, strong) NSArray* medium;
@property (nonatomic, strong) CBSenderInfo* sender;

@end

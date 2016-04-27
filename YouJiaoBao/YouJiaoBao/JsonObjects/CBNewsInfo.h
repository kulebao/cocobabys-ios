//
//  CBNewsInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

@interface CBNewsInfo : CSJsonObject
@property (nonatomic, strong) NSNumber* news_id;
@property (nonatomic, strong) NSNumber* class_id;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSNumber* feedback_required;
@property (nonatomic, strong) NSString* image;
@property (nonatomic, strong) NSNumber* notice_type;
@property (nonatomic, strong) NSNumber* published;
@property (nonatomic, strong) NSString* publisher_id;
@property (nonatomic, strong) NSNumber* school_id;
@property (nonatomic, strong) NSArray* tags;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSString* title;

@end

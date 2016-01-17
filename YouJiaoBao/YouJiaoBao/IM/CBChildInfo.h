//
//  CBChildInfo.h
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

/*
 {"child_id":"2_8901_77","name":"李博文","nick":"李博文","birthday":"2009-01-21","gender":1,"portrait":"https://dn-kulebao.qbox.me/3_2001_1430286902845/148a61fec5fbe9a6f2678675a4a2b444.jpg","class_id":20001,"class_name":"河马班","timestamp":1442572856782,"school_id":8901,"address":"骑龙2期","status":1,"created_at":0,"id":5555},
 */
@interface CBChildInfo : CSJsonObject

@property (nonatomic, strong) NSString* child_id;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* nick;
@property (nonatomic, strong) NSString* birthday;
@property (nonatomic, strong) NSNumber* gender;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, strong) NSNumber* class_id;
@property (nonatomic, strong) NSString* class_name;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSNumber* school_id;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSNumber* status;
@property (nonatomic, strong) NSNumber* created_at;
@property (nonatomic, strong) NSNumber* _id;

- (NSString *)displayNick;
- (NSString *)displayAge;

@end

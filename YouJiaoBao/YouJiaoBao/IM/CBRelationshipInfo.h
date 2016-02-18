//
//  CBRelationshipInfo.h
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

/*
 {"parent":{"parent_id":"1_8901_305","school_id":8901,"name":"赵若涵的妈妈","phone":"18908199765","portrait":"https://dn-kulebao.qbox.me/3_8901_1419835715696/6.jpg","gender":0,"birthday":"1967-04-03","timestamp":1447052090580,"member_status":1,"status":1,"company":"","created_at":0,"id":7972},
 "child":{"child_id":"2_8901_77","name":"李博文","nick":"李博文","birthday":"2009-01-21","gender":1,"portrait":"https://dn-kulebao.qbox.me/3_2001_1430286902845/148a61fec5fbe9a6f2678675a4a2b444.jpg","class_id":20001,"class_name":"河马班","timestamp":1442572856782,"school_id":8901,"address":"骑龙2期","status":1,"created_at":0,"id":5555},
 "card":"0009998201","relationship":"父亲","id":11706},
 */


#import "CBChildInfo.h"
#import "CBParentInfo.h"

@interface CBRelationshipInfo : CSJsonObject

@property (nonatomic, strong) NSNumber* _id;
@property (nonatomic, strong) NSString* card;
@property (nonatomic, strong) NSString* relationship;
@property (nonatomic, strong) CBChildInfo* child;
@property (nonatomic, strong) CBParentInfo* parent;

@end

//
//  CBTeacherInfo.h
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

/*
 {"id":"3_8901_1419835715696",
 "name":"毛毛虫大的国务卿儿的人",
 "phone":"15828234717",
 "gender":0,
 "workgroup":"校长",
 "workduty":"员工",
 "portrait":"",
 "birthday":"1985-08-02",
 "school_id":8901,
 "login_name":"admin8901",
 "timestamp":1448859098668,
 "privilege_group":"principal",
 "status":1,
 "created_at":1419835715697,
 "uid":1267}
 */
@interface CBTeacherInfo : CSJsonObject


@property (nonatomic, strong) NSString* _id;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSNumber* gender;
@property (nonatomic, strong) NSString* workgroup;
@property (nonatomic, strong) NSString* workduty;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, strong) NSString* birthday;
@property (nonatomic, strong) NSNumber* school_id;
@property (nonatomic, strong) NSString* login_name;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSNumber* status;
@property (nonatomic, strong) NSString* privilege_group;
@property (nonatomic, strong) NSNumber* created_at;

@end

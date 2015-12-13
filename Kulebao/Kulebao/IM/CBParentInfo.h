//
//  CBParentInfo.h
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

/*
 {"parent_id":"1_8901_97113637710893",
 "school_id":8901,
 "name":"张芬",
 "phone":"13637710893",
 "portrait":"https://dn-cocobabys.qbox.me/Q29jb2JhYnkxNDQ4MzMwMzg3OTU3",
 "gender":0,
 "birthday":"1984-09-03",
 "timestamp":1448330344971,
 "member_status":1,
 "status":1,
 "company":"",
 "created_at":1448330344971,
 "id":10537},
 */
@interface CBParentInfo : CSJsonObject

@property (nonatomic, strong) NSString* parent_id;
@property (nonatomic, strong) NSString* school_id;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* portrait;
@property (nonatomic, strong) NSNumber* gender;
@property (nonatomic, strong) NSString* birthday;
@property (nonatomic, strong) NSNumber* timestamp;
@property (nonatomic, strong) NSNumber* member_status;
@property (nonatomic, strong) NSNumber* status;
@property (nonatomic, strong) NSString* company;
@property (nonatomic, strong) NSNumber* created_at;
@property (nonatomic, strong) NSNumber* ssid;

@end

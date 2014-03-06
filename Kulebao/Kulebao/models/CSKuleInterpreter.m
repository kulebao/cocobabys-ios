//
//  CSKuleInterpreter.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleInterpreter.h"

@implementation CSKuleInterpreter

+ (CSKuleLoginInfo*)decodeLoginInfo:(NSDictionary*)dataJson {
    /*
     {
     "error_code" : 0,
     "access_token" : "1390314328393",
     "username" : "袋鼠",
     "account_name" : "13408654680",
     "school_name" : "天之骄子幼儿园"
     }
     */
    
    NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
    NSString* account_name = [dataJson valueForKeyNotNull:@"account_name"];
    NSString* school_name = [dataJson valueForKeyNotNull:@"school_name"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* username = [dataJson valueForKeyNotNull:@"username"];
    NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
    
    CSKuleLoginInfo* obj = [CSKuleLoginInfo new];
    obj.accessToken = access_token;
    obj.accountName = account_name;
    obj.schoolName = school_name;
    obj.username = username;
    obj.schoolId = school_id;
    obj.errorCode = error_code;
    
    return obj;
}

+ (CSKuleBindInfo*)decodeBindInfo:(NSDictionary*)dataJson {
    /*
     {
     "error_code" : 0,
     "access_token" : "1390314328393",
     "username" : "袋鼠",
     "account_name" : "13408654680",
     "school_id" : 93740362,
     "school_name" : "天之骄子幼儿园"
     }
     */
    
    NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
    NSString* username = [dataJson valueForKeyNotNull:@"username"];
    NSString* account_name = [dataJson valueForKeyNotNull:@"account_name"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* school_name = [dataJson valueForKeyNotNull:@"school_name"];
    NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
    
    CSKuleBindInfo* obj = [CSKuleBindInfo new];
    obj.accessToken = access_token;
    obj.accountName = account_name;
    obj.schoolName = school_name;
    obj.username = username;
    obj.schoolId = school_id;
    obj.errorCode = error_code;
    
    return obj;
}

+ (CSKuleRelationshipInfo*)decodeRelationshipInfo:(NSDictionary*)dataJson {
    /*
     {
     "parent" : {...},
     "child" : {...},
     "card" : "2133123232",
     "relationship" : "爸爸"
     }
     */
    
    NSString* relationship = [dataJson valueForKeyNotNull:@"relationship"];
    NSString* card = [dataJson valueForKeyNotNull:@"card"];
    
    CSKuleChildInfo* child = [CSKuleInterpreter decodeChildInfo:[dataJson valueForKeyNotNull:@"child"]];
    
    CSKuleParentInfo* parent = [CSKuleInterpreter decodeParentInfo:[dataJson valueForKeyNotNull:@"parent"]];
    
    CSKuleRelationshipInfo* obj = [CSKuleRelationshipInfo new];
    obj.relationship = relationship;
    obj.card = card;
    obj.child = child;
    obj.parent = parent;
    
    return obj;
}

+ (CSKuleChildInfo*)decodeChildInfo:(NSDictionary*)dataJson {
    /*
     {
     "child_id" : "1_1393768956259",
     "name" : "袋鼠小朋友",
     "nick" : "袋鼠小朋",
     "birthday" : "2009-01-01",
     "gender" : 1,
     "portrait" : "/assets/images/portrait_placeholder.png",
     "class_id" : 777888,
     "className" : "苹果班"
     }
     */
    
    NSString* child_id = [dataJson valueForKeyNotNull:@"child_id"];
    NSString* name = [dataJson valueForKeyNotNull:@"name"];
    NSString* nick = [dataJson valueForKeyNotNull:@"nick"];
    NSString* birthday = [dataJson valueForKeyNotNull:@"birthday"];
    NSInteger gender = [[dataJson valueForKeyNotNull:@"gender"] integerValue];
    NSString* portrait = [dataJson valueForKeyNotNull:@"portrait"];
    NSInteger class_id = [[dataJson valueForKeyNotNull:@"class_id"] integerValue];
    NSString* className = [dataJson valueForKeyNotNull:@"className"];
    
    CSKuleChildInfo* obj = [CSKuleChildInfo new];
    obj.childId = child_id;
    obj.name = name;
    obj.nick = nick;
    obj.birthday = birthday;
    obj.gender = gender;
    obj.portrait = portrait;
    obj.classId = class_id;
    obj.className = className;
    
    return obj;
}

+ (CSKuleParentInfo*)decodeParentInfo:(NSDictionary*)dataJson {
    /*
     {
     "id" : "2_1394011814045",
     "school_id" : 93740362,
     "name" : "飞哥",
     "phone" : "13800138001",
     "portrait" : "/assets/images/portrait_placeholder.png",
     "gender" : 0,
     "birthday" : "1980-01-01"
     }
     */
    
    NSString* parent_id = [dataJson valueForKeyNotNull:@"id"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* name = [dataJson valueForKeyNotNull:@"name"];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSString* portrait = [dataJson valueForKeyNotNull:@"portrait"];
    NSInteger gender = [[dataJson valueForKeyNotNull:@"gender"] integerValue];
    NSString* birthday = [dataJson valueForKeyNotNull:@"birthday"];
    
    CSKuleParentInfo* obj = [CSKuleParentInfo new];
    obj.parentId = parent_id;
    obj.schoolId = school_id;
    obj.name = name;
    obj.phone = phone;
    obj.portrait = portrait;
    obj.gender = gender;
    obj.birthday = birthday;
    
    return obj;
}

@end

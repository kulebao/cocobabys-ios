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
    
    NSParameterAssert(dataJson);
    
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
    
    NSParameterAssert(dataJson);
    
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
    
    NSParameterAssert(dataJson);
    
    NSString* relationship = [dataJson valueForKeyNotNull:@"relationship"];
    NSString* card = [dataJson valueForKeyNotNull:@"card"];
    
    CSKuleChildInfo* child = nil;
    id childJson = [dataJson valueForKeyNotNull:@"child"];
    if (childJson) {
        child = [CSKuleInterpreter decodeChildInfo:[dataJson valueForKeyNotNull:@"child"]];
    }

    CSKuleParentInfo* parent = nil;
    id parentJson = [dataJson valueForKeyNotNull:@"parent"];
    if (parentJson) {
        parent = [CSKuleInterpreter decodeParentInfo:parentJson];
    }
    
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
    
    NSParameterAssert(dataJson);
    
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
    
    NSParameterAssert(dataJson);
    
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

+ (CSKuleNewsInfo*)decodeNewsInfo:(NSDictionary*)dataJson {
    /*
     {
     "news_id" : 292,
     "school_id" : 93740362,
     "title" : "新标题",
     "content" : "新内容",
     "timestamp" : 1393511644614,
     "published" : true,
     "notice_type" : 2
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger news_id = [[dataJson valueForKeyNotNull:@"news_id"] integerValue];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* title = [dataJson valueForKeyNotNull:@"title"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    BOOL published = [[dataJson valueForKeyNotNull:@"published"] boolValue];
    NSInteger notice_type = [[dataJson valueForKeyNotNull:@"notice_type"] integerValue];
    
    CSKuleNewsInfo* obj = [CSKuleNewsInfo new];
    obj.newsId = news_id;
    obj.schoolId = school_id;
    obj.title = title;
    obj.content = content;
    obj.timestamp = timestamp/1000.0;
    obj.published = published;
    obj.noticeType = notice_type;
    
    return obj;
}

+ (CSKuleCookbookInfo*)decodeCookbookInfo:(NSDictionary*)dataJson {
    /*
     {
     "error_code" : 0,
     "school_id" : 93740362,
     "cookbook_id" : 179,
     "timestamp" : 1394356587696,
     "extra_tip" : "xxx",
     "week" : {
        "mon" : {...},
        "tue" : {...},
        "wed" : {...},
        "thu" : {...},
        "fri" : {...}
        }
     }
     */
    
    NSParameterAssert(dataJson);
    
    
    NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSInteger cookbook_id = [[dataJson valueForKeyNotNull:@"cookbook_id"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSString* extra_tip = [dataJson valueForKeyNotNull:@"extra_tip"];
    
    NSDictionary* week = [dataJson valueForKeyNotNull:@"week"];
    
    CSKuleRecipeInfo* mon = nil;
    CSKuleRecipeInfo* tue = nil;
    CSKuleRecipeInfo* wed = nil;
    CSKuleRecipeInfo* thu = nil;
    CSKuleRecipeInfo* fri = nil;
    
    if (week) {
        id monJson = [week valueForKeyNotNull:@"mon"];
        if (monJson) {
            mon = [CSKuleInterpreter decodeRecipeInfo:monJson];
        }
        
        id tueJson = [week valueForKeyNotNull:@"tue"];
        if (tueJson) {
            tue = [CSKuleInterpreter decodeRecipeInfo:tueJson];
        }
        
        id wedJson = [week valueForKeyNotNull:@"wed"];
        if (wedJson) {
            wed = [CSKuleInterpreter decodeRecipeInfo:wedJson];
        }
        
        id thuJson = [week valueForKeyNotNull:@"thu"];
        if (thuJson) {
            thu = [CSKuleInterpreter decodeRecipeInfo:thuJson];
        }
        
        id friJson = [week valueForKeyNotNull:@"fri"];
        if (friJson) {
            fri = [CSKuleInterpreter decodeRecipeInfo:friJson];
        }
    }
    
    CSKuleCookbookInfo* obj = [CSKuleCookbookInfo new];
    obj.errorCode = error_code;
    obj.schoolId = school_id;
    obj.cookbookId = cookbook_id;
    obj.timestamp = timestamp/1000.0;
    obj.extraTip = extra_tip;
    
    obj.mon = mon;
    obj.tue = tue;
    obj.wed = wed;
    obj.thu = thu;
    obj.fri = fri;
    
    return obj;
}

+ (CSKuleRecipeInfo*)decodeRecipeInfo:(NSDictionary*)dataJson {
    /*
     {
     "breakfast" : "牛大爷、鸡蛋、蛋糕,包子",
     "lunch" : "番茄鸡蛋面",
     "dinner" : "小鸡烧蘑菇，猪肉炖粉条",
     "extra" : "包子"
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSString* breakfast = [dataJson valueForKeyNotNull:@"breakfast"];
    NSString* lunch = [dataJson valueForKeyNotNull:@"lunch"];
    NSString* dinner = [dataJson valueForKeyNotNull:@"dinner"];
    NSString* extra = [dataJson valueForKeyNotNull:@"extra"];
    
    CSKuleRecipeInfo* obj = [CSKuleRecipeInfo new];
    obj.breakfast = breakfast;
    obj.lunch = lunch;
    obj.dinner = dinner;
    obj.extra = extra;
    
    return obj;
}


@end

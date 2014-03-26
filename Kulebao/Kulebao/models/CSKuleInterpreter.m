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
     "class_name" : "苹果班"
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
    NSString* className = [dataJson valueForKeyNotNull:@"class_name"];
    
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
     "notice_type" : 2,
     "image" : "http://suoqin-test.u.qiniudn.com/Fmz0zi5Y7qZw1spdUidluOQ2PvXm",
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger news_id = [[dataJson valueForKeyNotNull:@"news_id"] integerValue];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSInteger class_id = [[dataJson valueForKeyNotNull:@"class_id"] integerValue];
    NSString* title = [dataJson valueForKeyNotNull:@"title"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    NSString* image = [dataJson valueForKeyNotNull:@"image"];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    BOOL published = [[dataJson valueForKeyNotNull:@"published"] boolValue];
    NSInteger notice_type = [[dataJson valueForKeyNotNull:@"notice_type"] integerValue];
    
    CSKuleNewsInfo* obj = [CSKuleNewsInfo new];
    obj.newsId = news_id;
    obj.schoolId = school_id;
    obj.classId = class_id;
    obj.title = title;
    obj.content = content;
    obj.image = image;
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

+ (CSKuleAssignmentInfo*)decodeAssignmentInfo:(NSDictionary*)dataJson {
    /*
     {
     "id" : 4,
     "timestamp" : 1393344722731,
     "title" : "老师再见。",
     "content" : "今天请带一只小兔子回家。1",
     "publisher" : "杨老师",
     "icon_url" : "http://suoqin-test.u.qiniudn.com/FgPmIcRG6BGocpV1B9QMCaaBQ9LK",
     "class_id" : 777666
     },
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger assignment_id = [[dataJson valueForKeyNotNull:@"id"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSString* title = [dataJson valueForKeyNotNull:@"title"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    NSString* publisher = [dataJson valueForKeyNotNull:@"publisher"];
    NSString* icon_url = [dataJson valueForKeyNotNull:@"icon_url"];
    NSInteger class_id = [[dataJson valueForKeyNotNull:@"class_id"] integerValue];
    
    CSKuleAssignmentInfo* obj = [CSKuleAssignmentInfo new];
    obj.assignmentId = assignment_id;
    obj.timestamp = timestamp / 1000.0;
    obj.title = title;
    obj.content = content;
    obj.publisher = publisher;
    obj.iconUrl = icon_url;
    obj.classId = class_id;
    
    return obj;
}

+ (CSKuleScheduleInfo*)decodeScheduleInfo:(NSDictionary*)dataJson {
    /*
     [ {
     "error_code" : 0,
     "school_id" : 93740362,
     "class_id" : 777666,
     "schedule_id" : 124,
     "timestamp" : 1394642036374,
     "week" : {...}
     } ]
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSInteger class_id = [[dataJson valueForKeyNotNull:@"class_id"] integerValue];
    NSInteger schedule_id = [[dataJson valueForKeyNotNull:@"schedule_id"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    
    CSKuleWeekScheduleInfo* weekInfo = nil;
    id weekJson = [dataJson valueForKeyNotNull:@"week"];
    if (weekJson) {
        weekInfo = [CSKuleInterpreter decodeWeekScheduleInfo:weekJson];
    }

    CSKuleScheduleInfo* obj = [CSKuleScheduleInfo new];
    obj.errorCode = error_code;
    obj.schoolId = school_id;
    obj.classId = class_id;
    obj.scheduleId = schedule_id;
    obj.timestamp = timestamp / 1000.0;
    obj.week = weekInfo;
    
    return obj;
}

+ (CSKuleWeekScheduleInfo*)decodeWeekScheduleInfo:(NSDictionary*)dataJson {
    /*
     {
     "mon" : {...},
     "tue" : {...},
     "wed" : {...},
     "thu" : {...},
     "fri" : {...}
     }
     */
    
    NSParameterAssert(dataJson);
    
    CSKuleDailyScheduleInfo* mon = nil;
    CSKuleDailyScheduleInfo* tue = nil;
    CSKuleDailyScheduleInfo* wed = nil;
    CSKuleDailyScheduleInfo* thu = nil;
    CSKuleDailyScheduleInfo* fri = nil;
    
    id monJson = [dataJson valueForKeyNotNull:@"mon"];
    if (monJson) {
        mon = [CSKuleInterpreter decodeDailyScheduleInfo:monJson];
    }
    
    id tueJson = [dataJson valueForKeyNotNull:@"tue"];
    if (tueJson) {
        tue = [CSKuleInterpreter decodeDailyScheduleInfo:tueJson];
    }
    
    id wedJson = [dataJson valueForKeyNotNull:@"wed"];
    if (wedJson) {
        wed = [CSKuleInterpreter decodeDailyScheduleInfo:wedJson];
    }
    
    id thuJson = [dataJson valueForKeyNotNull:@"thu"];
    if (thuJson) {
        thu = [CSKuleInterpreter decodeDailyScheduleInfo:thuJson];
    }
    
    id friJson = [dataJson valueForKeyNotNull:@"fri"];
    if (friJson) {
        fri = [CSKuleInterpreter decodeDailyScheduleInfo:friJson];
    }
    
    CSKuleWeekScheduleInfo* obj = [CSKuleWeekScheduleInfo new];
    obj.mon = mon;
    obj.tue = tue;
    obj.wed = wed;
    obj.thu = thu;
    obj.fri = fri;
    
    return obj;
}

+ (CSKuleDailyScheduleInfo*)decodeDailyScheduleInfo:(NSDictionary*)dataJson {
    /*
     {
     "am" : "钳工",
     "pm" : "政治"
     }
     */

    NSParameterAssert(dataJson);
    
    NSString* am = [dataJson valueForKeyNotNull:@"am"];
    NSString* pm = [dataJson valueForKeyNotNull:@"pm"];
    
    CSKuleDailyScheduleInfo* obj = [CSKuleDailyScheduleInfo new];
    obj.am = am;
    obj.pm = pm;
    
    return obj;
}

+ (CSKuleSchoolInfo*)decodeSchoolInfo:(NSDictionary*)dataJson {
    /*
     {"school_id":93740362,
     "phone":"13991855476",
     "timestamp":1387649057933,
     "desc":"...",
     "school_logo_url":"http://www.jslfgz.com.cn/UploadFiles/xxgl/2013/4/201342395834.jpg", 
     "name":"成都市第三军区幼儿园"
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSString* desc = [dataJson valueForKeyNotNull:@"desc"];
    NSString* school_logo_url = [dataJson valueForKeyNotNull:@"school_logo_url"];
    NSString* name = [dataJson valueForKeyNotNull:@"name"];
    
    CSKuleSchoolInfo* obj = [CSKuleSchoolInfo new];
    obj.schoolId = school_id;
    obj.phone = phone;
    obj.desc = desc;
    obj.timestamp = timestamp / 1000.0;
    obj.schoolLogoUrl = school_logo_url;
    obj.name = name;
    
    return obj;
}

+ (CSKuleCheckInOutLogInfo*)decodeCheckInOutLogInfo:(NSDictionary*)dataJson {
    /*
     {
     "timestamp":1393766772899,
     "notice_type":1,
     "child_id":"1_93740362_374",
     "pushid":"815206836867002199",
     "record_url":"http://suoqin-test.u.qiniudn.com/FoUJaV4r5L0bM0414mGWEIuCLEdL",
     "parent_name":"林玄",
     "device":3},
     */
    
    NSParameterAssert(dataJson);
        
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSInteger notice_type = [[dataJson valueForKeyNotNull:@"notice_type"] integerValue];
    NSString* child_id = [dataJson valueForKeyNotNull:@"child_id"];
    NSString* pushid = [dataJson valueForKeyNotNull:@"pushid"];
    NSString* record_url = [dataJson valueForKeyNotNull:@"record_url"];
    NSString* parent_name = [dataJson valueForKeyNotNull:@"parent_name"];
    NSInteger device = [[dataJson valueForKeyNotNull:@"device"] integerValue];
    
    CSKuleCheckInOutLogInfo* obj = [CSKuleCheckInOutLogInfo new];
    obj.timestamp = timestamp / 1000.0;
    obj.noticeType = notice_type;
    obj.childId = child_id;
    obj.pushId = pushid;
    obj.recordUrl = record_url;
    obj.parentName = parent_name;
    obj.deviceType = device;
    
    return obj;
}

+ (CSKuleChatMsg*)decodeChatMsg:(NSDictionary*)dataJson {
    
    /*
     {
     "phone":"123456789",
     "timestamp":1392967799188,
     "id":1392967799188,
     "content":"谢谢你的鼓励", 
     "image":"http://suoqin-test.u.qiniudn.com/Fget0Tx492DJofAy-ZeUg1SANJ4X",
     "sender":"带班老师"
     }
     */
    
    NSParameterAssert(dataJson);
    
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    long long msgId = [[dataJson valueForKeyNotNull:@"id"] longLongValue];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    NSString* image = [dataJson valueForKeyNotNull:@"image"];
    NSString* sender = [dataJson valueForKeyNotNull:@"sender"];
    
    CSKuleChatMsg* obj = [CSKuleChatMsg new];
    obj.timestamp = timestamp / 1000.0;
    obj.msgId = msgId;
    obj.phone = phone;
    obj.content = content;
    obj.image = image;
    obj.sender = sender;
    
    return obj;
}

+ (CSKuleAssessInfo*)decodeAssessInfo:(NSDictionary*)dataJson {
    /*
     {
     "id":4,
     "timestamp":12314313123,
     "publisher":"杨老师",
     "comments":"我这周请假了",
     "emotion":3,
     "dining":3,
     "rest":3,
     "activity":3,
     "game":3,
     "exercise":3,
     "self_care":3,
     "manner":3,
     "child_id":"1_93740362_456",
     "school_id":93740362
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger assessId = [[dataJson valueForKeyNotNull:@"id"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSString* publisher = [dataJson valueForKeyNotNull:@"publisher"];
    NSString* comments = [dataJson valueForKeyNotNull:@"comments"];
    NSString* child_id = [dataJson valueForKeyNotNull:@"child_id"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    
    
    NSInteger emotion = [[dataJson valueForKeyNotNull:@"emotion"] integerValue];
    NSInteger dining = [[dataJson valueForKeyNotNull:@"dining"] integerValue];
    NSInteger rest = [[dataJson valueForKeyNotNull:@"rest"] integerValue];
    NSInteger activity = [[dataJson valueForKeyNotNull:@"activity"] integerValue];
    NSInteger game = [[dataJson valueForKeyNotNull:@"game"] integerValue];
    NSInteger exercise = [[dataJson valueForKeyNotNull:@"exercise"] integerValue];
    NSInteger self_care = [[dataJson valueForKeyNotNull:@"self_care"] integerValue];
    NSInteger manner = [[dataJson valueForKeyNotNull:@"manner"] integerValue];
    
    CSKuleAssessInfo* obj = [CSKuleAssessInfo new];
    obj.timestamp = timestamp / 1000.0;
    obj.assessId = assessId;
    obj.publisher = publisher;
    obj.comments = comments;
    obj.childId = child_id;
    obj.schoolId = school_id;
    obj.emotion = emotion;
    obj.dining = dining;
    obj.rest = rest;
    obj.activity = activity;
    obj.game = game;
    obj.exercise = exercise;
    obj.selfcare = self_care;
    obj.manner = manner;
    
    return obj;
}

@end

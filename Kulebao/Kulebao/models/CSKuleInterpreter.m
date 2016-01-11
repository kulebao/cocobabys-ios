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
     "school_name" : "天之骄子幼儿园",
     "member_status":"free",
     "im_token" =     {
     source = db;
     token = "9YG/W9G5Lbp22JfU5qhO0ss8c+62KOdje+2Xo/9p21sVElVu7QBMFQF1v7nNTtxUORuWt30JHu72PVzAPWSP7Hn7m3YilJJ19jxWixZT/zxLLzOxwaIezGJa73m3bFGj";
     "user_id" = "p_8901_Some(9331)_18782242007";
     };
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSString* access_token = [dataJson valueForKeyNotNull:@"access_token"];
    NSString* username = [dataJson valueForKeyNotNull:@"username"];
    NSString* account_name = [dataJson valueForKeyNotNull:@"account_name"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* school_name = [dataJson valueForKeyNotNull:@"school_name"];
    NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
    NSString* member_status = [dataJson valueForKeyNotNull:@"member_status"];
    
    NSDictionary* im_token = [dataJson valueForKeyNotNull:@"im_token"];
    
    
    CSKuleBindInfo* obj = [CSKuleBindInfo new];
    obj.accessToken = access_token;
    obj.accountName = account_name;
    obj.schoolName = school_name;
    obj.username = username;
    obj.schoolId = school_id;
    obj.errorCode = error_code;
    obj.memberStatus = member_status;
    obj.imToken = [CBIMTokenData instanceWithDictionary:im_token];
    
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
    obj.uid = [[dataJson valueForKeyNotNull:@"id"] integerValue];
    
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
     {"parent_id":"2_93740362_790",
     "school_id":93740362,
     "name":"老虎",
     "phone":"13408654683",
     "portrait":"",
     "gender":0,
     "birthday":"1799-12-31",
     "timestamp":0,
     "member_status":1,
     "status":1,
     "company":"ZTE"}
     */
    
    NSParameterAssert(dataJson);
    
    NSString* parent_id = [dataJson valueForKeyNotNull:@"parent_id"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* name = [dataJson valueForKeyNotNull:@"name"];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSString* portrait = [dataJson valueForKeyNotNull:@"portrait"];
    NSInteger gender = [[dataJson valueForKeyNotNull:@"gender"] integerValue];
    NSString* birthday = [dataJson valueForKeyNotNull:@"birthday"];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSInteger memberStatus = [[dataJson valueForKeyNotNull:@"member_status"] integerValue];
    NSInteger status = [[dataJson valueForKeyNotNull:@"status"] integerValue];
    NSString* company = [dataJson valueForKeyNotNull:@"company"];
    
    CSKuleParentInfo* obj = [CSKuleParentInfo new];
    obj.parentId = parent_id;
    obj.schoolId = school_id;
    obj.name = name;
    obj.phone = phone;
    obj.portrait = portrait;
    obj.gender = gender;
    obj.birthday = birthday;
    obj.timestamp = timestamp / 1000.0;
    obj.memberStatus = memberStatus;
    obj.status = status;
    obj.company = company;
    
    return obj;
}

+ (CSKuleNewsInfo*)decodeNewsInfo:(NSDictionary*)dataJson {
    /*
     {
     "news_id":11,
     "school_id":93740362,
     "title":"通知14",
     "content":"测试信息",
     "timestamp":1426691242108,
     "published":true,
     "notice_type":2,
     "class_id":0,
     "image":"",
     "publisher_id":"3_93740362_3344",
     "feedback_required":false,
     "tags":["作业","活动"]
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
    
    NSString* publisher_id = [dataJson valueForKeyNotNull:@"publisher_id"];
    BOOL feedback_required = [[dataJson valueForKeyNotNull:@"feedback_required"] boolValue];
    NSArray* tags = [dataJson valueForKeyNotNull:@"tags"];
    
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
    obj.publisherId = publisher_id;
    obj.feedbackRequired = feedback_required;
    obj.tags = tags;
    
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
     {
     address = "\U963f\U65af\U52a0\U5c14\U5fb7\Uff08\U725b\U903c\U5427\Uff09";
     desc = "";
     "full_name" = "\U738b\U946b\U8d85\U7ea7\U5e7c\U513f\U56ed";
     name = "\U738b\U946b\U8d85\U7ea7\U5e7c\U513f\U56ed";
     phone = 18782242007;
     properties =     (
     );
     "school_id" = 9028;
     "school_logo_url" = "";
     timestamp = 1428476926181;
     token = 3DA866E3D78612FDD3D7EDF5D610732E34B5C005B163CC8E;
     }
     */
    
    NSParameterAssert(dataJson);
    
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSString* desc = [dataJson valueForKeyNotNull:@"desc"];
    NSString* school_logo_url = [dataJson valueForKeyNotNull:@"school_logo_url"];
    NSString* name = [dataJson valueForKeyNotNull:@"name"];
    NSString* fullName = [dataJson valueForKeyNotNull:@"full_name"];
    NSString* address = [dataJson valueForKeyNotNull:@"address"];
    NSArray* properties = [dataJson valueForKeyNotNull:@"properties"];
    NSString* token = [dataJson valueForKeyNotNull:@"token"];
    
    CSKuleSchoolInfo* obj = [CSKuleSchoolInfo new];
    obj.schoolId = school_id;
    obj.phone = phone;
    obj.desc = desc;
    obj.timestamp = timestamp / 1000.0;
    obj.schoolLogoUrl = school_logo_url;
    obj.fullName = fullName;
    obj.name = name;
    obj.address = address;
    obj.properties = properties;
    obj.token = token;
    
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
     "sender":"带班老师",
     "sender_id":""
     }
     */
    
    NSParameterAssert(dataJson);
    
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    long long msgId = [[dataJson valueForKeyNotNull:@"id"] longLongValue];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    NSString* image = [dataJson valueForKeyNotNull:@"image"];
    NSString* sender = [dataJson valueForKeyNotNull:@"sender"];
    NSString* sender_id = [dataJson valueForKeyNotNull:@"sender_id"];
    
    CSKuleChatMsg* obj = [CSKuleChatMsg new];
    obj.timestamp = timestamp / 1000.0;
    obj.msgId = msgId;
    obj.phone = phone;
    obj.content = content;
    obj.image = image;
    obj.sender = sender;
    obj.senderId = sender_id;
    
    return obj;
}


+ (CSKuleMediaInfo*)decodeMediaInfo:(NSDictionary*)dataJson {
    CSKuleMediaInfo* obj = nil;
    if (dataJson) {
        NSString* url = [dataJson valueForKeyNotNull:@"url"];
        NSString* type = [dataJson valueForKeyNotNull:@"type"];
        
        obj = [CSKuleMediaInfo new];
        obj.url = url;
        obj.type = type;
    }
    return obj;
}

+ (CSKuleSenderInfo*)decodeSenderInfo:(NSDictionary*)dataJson {
    CSKuleSenderInfo* obj = nil;
    if (dataJson) {
        NSString* senderId = [dataJson valueForKeyNotNull:@"id"];
        NSString* type = [dataJson valueForKeyNotNull:@"type"];
        
        obj = [CSKuleSenderInfo new];
        obj.senderId = senderId;
        obj.type = type;
    }
    return obj;
}

+ (CSKuleTopicMsg*)decodeTopicMsg:(NSDictionary*)dataJson {
    /*
     {"topic":"1_1396844597394",
     "timestamp":112312313123,
     "id":1,
     "content":"老师你好，我们家王大侠怎么样。",
     "media":{"url":"http://suoqin-test.u.qiniudn.com/FgPmIcRG6BGocpV1B9QMCaaBQ9LK","type":"image"},
     "sender":{"id":"2_1003_1396844438388","type":"p"}
     }
     */
    
    NSParameterAssert(dataJson);
    
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    long long msgId = [[dataJson valueForKeyNotNull:@"id"] longLongValue];
    NSString* topic = [dataJson valueForKeyNotNull:@"topic"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    
    CSKuleSenderInfo* sender = [CSKuleInterpreter decodeSenderInfo:[dataJson valueForKeyNotNull:@"sender"]];
    
    CSKuleMediaInfo* media = [CSKuleInterpreter decodeMediaInfo:[dataJson valueForKeyNotNull:@"media"]];

    CSKuleTopicMsg* obj = [CSKuleTopicMsg new];
    obj.timestamp = timestamp / 1000.0;
    obj.msgId = msgId;
    obj.topic = topic;
    obj.content = content;
    obj.media = media;
    obj.sender = sender;

    return obj;
}

+ (CSKuleHistoryInfo*)decodeHistoryInfo:(NSDictionary*)dataJson {
    NSParameterAssert(dataJson);
    
    /*
     {
     content = "\U6d4b\U8bd5\U770b\U7f51\U9875\U663e\U793a\U95ee\U9898";
     id = 796;
     medium =     (
     {
     type = image;
     url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_180338.jpg";
     },
     {
     type = image;
     url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_145407.jpg";
     }
     );
     sender =     {
     id = "3_2088_1403762507321";
     type = t;
     };
     timestamp = 1406449306043;
     topic = "2_2088_900";
     },
     */
    
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSInteger uid = [[dataJson valueForKeyNotNull:@"id"] integerValue];
    NSString* topic = [dataJson valueForKeyNotNull:@"topic"];
    NSString* content = [dataJson valueForKeyNotNull:@"content"];
    
    CSKuleSenderInfo* sender = [CSKuleInterpreter decodeSenderInfo:[dataJson valueForKeyNotNull:@"sender"]];
    
    NSArray* mediaList = [dataJson valueForKeyNotNull:@"medium"];
    NSMutableArray* mediumList = [NSMutableArray array];
    for (NSDictionary* mediaObject in mediaList) {
        CSKuleMediaInfo* media = [CSKuleInterpreter decodeMediaInfo:mediaObject];
        [mediumList addObject:media];
    }
    
    
    
    CSKuleHistoryInfo* obj = [CSKuleHistoryInfo new];
    obj.timestamp = timestamp / 1000.0;
    obj.uid = uid;
    obj.topic = topic;
    obj.content = content;
    obj.medium = mediumList;
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

+ (CSKuleEmployeeInfo*)decodeEmployeeInfo:(NSDictionary*)dataJson {
    /*
     {"id":"3_93740362_1122",
     "name":"王豫",
     "phone":"13258249821",
     "gender":0,
     "workgroup":"教师组",
     "workduty":"教师",
     "portrait":"",
     "birthday":"1986-06-04",
     "school_id":93740362,
     "login_name":"e0001",
     "timestamp":1394639512253, 
     "privilege_group":"principal"}
     */
    NSParameterAssert(dataJson);
    
    NSString* employeeId = [dataJson valueForKeyNotNull:@"id"];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    
    NSString* name = [dataJson valueForKeyNotNull:@"name"];
    NSString* phone = [dataJson valueForKeyNotNull:@"phone"];
    NSInteger gender = [[dataJson valueForKeyNotNull:@"gender"] integerValue];
    NSString* workgroup = [dataJson valueForKeyNotNull:@"workgroup"];
    NSString* workduty = [dataJson valueForKeyNotNull:@"workduty"];
    NSString* portrait = [dataJson valueForKeyNotNull:@"portrait"];
    NSString* login_name = [dataJson valueForKeyNotNull:@"login_name"];
    NSString* privilege_group = [dataJson valueForKeyNotNull:@"privilege_group"];
    
    CSKuleEmployeeInfo* obj = [CSKuleEmployeeInfo new];
    obj.timestamp = timestamp / 1000.0;
    obj.schoolId = school_id;
    obj.employeeId = employeeId;
    obj.name = name;
    obj.gender = gender;
    obj.phone = phone;
    obj.loginName = login_name;
    obj.workduty = workduty;
    obj.workgroup = workgroup;
    obj.privilegeGroup = privilege_group;
    obj.portrait = portrait;
    
    return obj;
}

+ (CSKuleVideoMember*)decodeVideoMember:(NSDictionary*)dataJson {
    /*
     {"id":"2_2088_1404306110633",
     "password":"dev_env_password",
     "account":"0758B3F3CD5F947A9120135C72EB115F",
     "school_id":2088},
     */
    NSParameterAssert(dataJson);
    
    NSString* uid = [dataJson valueForKeyNotNull:@"id"];
    NSString* account = [dataJson valueForKeyNotNull:@"account"];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSString* password = [dataJson valueForKeyNotNull:@"password"];
    
    CSKuleVideoMember* obj = [CSKuleVideoMember new];
    obj.uid = uid;
    obj.password = password;
    obj.account = account;
    obj.schoolId = school_id;
    
    return obj;
}

+ (CSKuleBusLocationInfo*)decodeBusLocation:(NSDictionary*)dataJson {
    /*
     {
     address = "\U56db\U5ddd\U7701\U6210\U90fd\U5e02\U53cc\U6d41\U53bf\U5143\U666f\U8def";
     "child_id" = "2_9028_52049";
     direction = "-1";
     "driver_id" = "3_9028_1428477866424";
     latitude = "30.53457";
     longitude = "104.055455";
     onBoard = 0;
     radius = "62.91685485839844";
     "school_id" = 9028;
     status = 1;
     timestamp = 1436106433250;
     }
     */
    NSParameterAssert(dataJson);
    
    NSString* address = [dataJson valueForKeyNotNull:@"address"];
    NSString* child_id = [dataJson valueForKeyNotNull:@"child_id"];
    NSInteger direction = [[dataJson valueForKeyNotNull:@"direction"] integerValue];
    NSString* driver_id = [dataJson valueForKeyNotNull:@"driver_id"];
    CGFloat latitude = [[dataJson valueForKeyNotNull:@"latitude"] floatValue];
    CGFloat longitude = [[dataJson valueForKeyNotNull:@"longitude"] floatValue];
    NSInteger onBoard = [[dataJson valueForKeyNotNull:@"onBoard"] integerValue];
    CGFloat radius = [[dataJson valueForKeyNotNull:@"radius"] floatValue];
    NSInteger school_id = [[dataJson valueForKeyNotNull:@"school_id"] integerValue];
    NSInteger status = [[dataJson valueForKeyNotNull:@"status"] integerValue];
    double timestamp = [[dataJson valueForKeyNotNull:@"timestamp"] doubleValue];
    
    CSKuleBusLocationInfo* obj = [CSKuleBusLocationInfo new];
    obj.address = address;
    obj.childId = child_id;
    obj.direction = direction;
    obj.driverId = driver_id;
    obj.latitude = latitude;
    obj.longitude = longitude;
    obj.onBoard = onBoard;
    obj.radius = radius;
    obj.schoolId = school_id;
    obj.timestamp = timestamp / 1000.0;
    obj.status = status;
    
    return obj;
}

@end

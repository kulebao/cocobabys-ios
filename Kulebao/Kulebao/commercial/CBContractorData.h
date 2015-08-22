//
//  CBContractorData.h
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityData.h"

/*
 {
 "id":25,
 "agent_id":1,
 "category":"培训教育",
 "title":"多图测试",
 "address":"111",
 "contact":"111",
 "time_span":"2015-08-13~2015-09-13",
 "detail":"111",
 "logos":[
    {"url":"https://dn-kulebao.qbox.me/a0001/activity.png"},
    {"url":"https://dn-kulebao.qbox.me/a0001/logo_wechatmoments.png"},
    {"url":"https://dn-kulebao.qbox.me/a0001/activity.png"}],
 "updated_at":1440049928124,
 "publishing":{"publish_status":4,"published_at":1439473189685},
 "priority":12
 },
 */

@interface CBContractorData : CSJsonEntityData

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger agent_id;
@property (nonatomic, strong) NSString* category;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* contact;
@property (nonatomic, strong) NSString* time_span;
@property (nonatomic, strong) NSString* detail;
@property (nonatomic, strong) NSArray* logos;
@property (nonatomic, assign) NSInteger updated_at;
@property (nonatomic, strong) CBPublishData* publishing;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) CBLocationData* location;

@end

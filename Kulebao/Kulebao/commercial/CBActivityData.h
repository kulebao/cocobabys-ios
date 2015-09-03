//
//  CBActivityData.h
//  youlebao
//
//  Created by xin.c.wang on 8/20/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CSJsonEntityData.h"

/*
 {
 "id":36,
 "agent_id":1,
 "contractor_id":14,
 "title":"活动多图测试",
 "address":"333",
 "contact":"3333",
 "time_span":"2015-08-13~2015-09-13",
 "detail":"ddd",
 "logos":[{"url":"https://dn-kulebao.qbox.me/a0001/activity.png"},{"url":"https://dn-kulebao.qbox.me/a0001/logo_wechatmoments.png"},{"url":"https://dn-kulebao.qbox.me/a0001/logo_wechatmoments.png"}],
 "updated_at":1439476161096,
 "publishing":{"publish_status":4,"published_at":1439476023393},
 "price":{"origin":333.0,"discounted":222.0},
 "priority":0,
 "location":{"latitude":104.0711850,"longitude":30.5959470,"address":""}
 }
 */

@class CBLogoData;
@class CBPublishData;
@class CBPriceData;
@class CBLocationData;

@interface CBActivityData : CSJsonEntityData

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger agent_id;
@property (nonatomic, assign) NSInteger contractor_id;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* contact;
@property (nonatomic, strong) NSString* time_span;
@property (nonatomic, strong) NSString* detail;
@property (nonatomic, strong) NSArray* logos;
@property (nonatomic, assign) NSInteger updated_at;
@property (nonatomic, strong) CBPublishData* publishing;
@property (nonatomic, strong) CBPriceData* price;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) CBLocationData* location;

@property (nonatomic, assign) BOOL joined;

@end

@interface CBLogoData : CSJsonEntityData
@property (nonatomic, strong) NSString* url;
@end

@interface CBPublishData : CSJsonEntityData

@property (nonatomic, assign) NSInteger publish_status;
@property (nonatomic, assign) NSInteger published_at;

@end

@interface CBPriceData : CSJsonEntityData

@property (nonatomic, strong) NSString* origin;
@property (nonatomic, strong) NSString* discounted;

@end

@interface CBLocationData : CSJsonEntityData

@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, strong) NSString* address;

@end
//
//  CBDailylogInfo.h
//  YouJiaoBao
//
//  Created by WangXin on 4/1/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CSJsonObject.h"

// 通知类型
enum KuleNoticeType {
    kKuleNoticeTypeCheckOut = 0,
    kKuleNoticeTypeCheckIn = 1,
    //早上上车，早上下车，下午上车，下午下车
    kKuleNoticeTypeCheckInCarMorning = 10,
    kKuleNoticeTypeCheckOutCarMorning = 11,
    kKuleNoticeTypeCheckInCarAfternoon = 12,
    kKuleNoticeTypeCheckOutCarAfternoon = 13,
};

@interface CBDailylogInfo : CSJsonObject

@property (nonatomic, strong) NSString* card;
@property (nonatomic, strong) NSString* child_id;
@property (nonatomic, strong) NSNumber* notice_type;
@property (nonatomic, strong) NSString* parent_name;
@property (nonatomic, strong) NSString* record_url;
@property (nonatomic, strong) NSNumber* timestamp;

- (BOOL)isToday;

@end

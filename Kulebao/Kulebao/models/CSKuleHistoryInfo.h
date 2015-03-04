//
//  CSKuleHistoryInfo.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-14.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSKuleMediaInfo.h"
#import "CSKuleSenderInfo.h"

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

@interface CSKuleHistoryInfo : NSObject

@property (nonatomic, strong) NSString* content;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, strong) NSArray* medium;
@property (nonatomic, strong) CSKuleSenderInfo* sender;
@property (nonatomic, strong) NSString* topic;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end

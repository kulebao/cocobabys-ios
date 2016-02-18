//
//  CBChatListViewController.h
//  youlebao
//
//  Created by WangXin on 12/3/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "CBIMNotificationUserInfo.h"

@interface CBIMChatListViewController : RCConversationListViewController


- (void)openChat:(CBIMNotificationUserInfo*)rcUserInfo;

@end

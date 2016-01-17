//
//  CBChatViewSettingsViewController.h
//  youlebao
//
//  Created by WangXin on 12/7/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBChatViewSettingsViewController;

@protocol CBChatViewSettingsViewControllerDelegate <NSObject>

@optional
- (void)chatViewSettingsViewControllerDidClearMsg:(CBChatViewSettingsViewController*)ctrl;

@end

@interface CBChatViewSettingsViewController : UITableViewController

@property(nonatomic, strong) NSString *targetId;
@property(nonatomic, weak) id<CBChatViewSettingsViewControllerDelegate> delegate;

@end

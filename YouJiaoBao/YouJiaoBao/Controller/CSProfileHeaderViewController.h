//
//  CSProfileHeaderViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSProfileHeaderViewController;

@protocol CSProfileHeaderViewControllerDelegate <NSObject>

@optional
- (void)profileHeaderViewControllerWillUpdateProfile:(CSProfileHeaderViewController*)ctrl;

@end

@interface CSProfileHeaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL moreDetails;

- (void)reloadData;

@end

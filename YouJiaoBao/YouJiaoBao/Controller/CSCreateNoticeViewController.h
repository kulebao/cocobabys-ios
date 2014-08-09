//
//  CSCreateNoticeViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-9.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSCreateNoticeViewController : UIViewController

@property (nonatomic, weak) id delegate;

@end


@protocol CSCreateNoticeViewControllerDelegate <NSObject>

- (void)createNoticeViewControllerSuccessed:(CSCreateNoticeViewController*)ctrl;

@end
//
//  CSChildProfileHeaderViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBChildInfo;

@interface CSChildProfileHeaderViewController : UIViewController
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) CBChildInfo* childInfo;

@end


@protocol CSChildProfileHeaderViewControllerDelegate <NSObject>

@optional
- (void)childProfileHeaderViewControllerShowAssessment:(CSChildProfileHeaderViewController*)ctrl;

@end
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
@property (nonatomic, assign) BOOL singleImage;

@end

@protocol CSCreateNoticeViewControllerDelegate <NSObject>
@optional

- (void)createNoticeViewController:(CSCreateNoticeViewController*)ctrl
                     finishEditText:(NSString*)text
                         withImages:(NSArray*)imageList;

- (void)createNoticeViewController:(CSCreateNoticeViewController*)ctrl
                    finishWithVideo:(NSURL*)videoLocalUrl;

@end
//
//  CSKuleChatingEditorViewController.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSKuleChatingEditorViewController : UIViewController

@property (nonatomic, weak) id delegate;

@end

@protocol CSKuleChatingEditorViewControllerDelegate <NSObject>
@optional
- (void)willSendMsgWithText:(NSString*)msgBody;

@end

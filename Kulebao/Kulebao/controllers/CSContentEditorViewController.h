//
//  CSContentEditorViewController.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-15.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSContentEditorViewController : UIViewController

@property (nonatomic, weak) id delegate;

@end

@protocol CSContentEditorViewControllerDelegate <NSObject>
@optional

- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl finishEditText:(NSString*)text withImages:(NSArray*)imageList;

@end
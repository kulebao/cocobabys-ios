//
//  CSClassPickerView.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityClassInfo.h"

@interface CSClassPickerView : UIView

@property (nonatomic, weak) id delegate;

+ (instancetype)defaultClassPickerView;

- (void)reset;

@end


@protocol CSClassPickerViewDelegate <NSObject>

@optional
- (void)classPickerViewDidOk:(CSClassPickerView*)view withClassInfo:(EntityClassInfo*)classInfo;
- (void)classPickerViewDidCancel:(CSClassPickerView*)view;

@end
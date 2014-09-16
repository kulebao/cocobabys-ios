//
//  CSClassPickerView.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSClassPickerView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL canSelectAll;

+ (instancetype)defaultClassPickerView;

- (void)reset;

@end


@protocol CSClassPickerViewDelegate <NSObject>

@optional
- (void)classPickerViewDidOk:(CSClassPickerView*)view withClassId:(NSNumber*)classId;
- (void)classPickerViewDidCancel:(CSClassPickerView*)view;

@end
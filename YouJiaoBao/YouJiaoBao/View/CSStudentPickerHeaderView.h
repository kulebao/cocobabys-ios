//
//  CSStudentPickerHeaderView.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModelClassData;

@interface CSStudentPickerHeaderView : UIView

@property (nonatomic, strong) ModelClassData* modelData;
@property (nonatomic, weak)  NSMutableSet* sharedSelectedChildren;

@property (nonatomic, weak) id delegate;

+ (instancetype)defaultClassHeaderView;

- (void)reloadData;

@end

@protocol CSStudentPickerHeaderViewDelegate <NSObject>
@optional
- (void)studentPickerHeaderViewExpandChanged:(CSStudentPickerHeaderView*)view;
- (void)studentPickerHeaderViewSelectionhanged:(CSStudentPickerHeaderView*)view;

@end
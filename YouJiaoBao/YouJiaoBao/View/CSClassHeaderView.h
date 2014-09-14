//
//  CSClassHeaderView.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModelClassData;

@interface CSClassHeaderView : UIView

@property (nonatomic, strong) ModelClassData* modelData;
@property (nonatomic, weak) id delegate;

+ (instancetype)defaultClassHeaderView;

@end

@protocol CSClassHeaderViewDelegate <NSObject>
@optional
- (void)classHeaderViewExpandChanged:(CSClassHeaderView*)view;

@end

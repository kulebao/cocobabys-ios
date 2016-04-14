//
//  CSClassHeaderView.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModelBaseData;

@interface CSClassHeaderView : UIView

@property (nonatomic, strong) ModelBaseData* modelData;
@property (nonatomic, weak) id delegate;

+ (instancetype)defaultClassHeaderView;

- (void)reloadData;

@end

@protocol CSClassHeaderViewDelegate <NSObject>
@optional
- (void)classHeaderViewExpandChanged:(CSClassHeaderView*)view;

@end

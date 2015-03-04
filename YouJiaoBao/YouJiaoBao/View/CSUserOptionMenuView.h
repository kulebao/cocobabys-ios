//
//  CSUserOptionMenuView.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-2.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSUserOptionMenuView;

@protocol CSUserOptionMenuViewDelegate <NSObject>

@optional
- (void)userOptionMenuView:(CSUserOptionMenuView*)view selectedMenuAtIndex:(NSUInteger)index;

@end

@interface CSUserOptionMenuView : UIView

@property (nonatomic, weak) id delegate;

+ (instancetype)userOptionMenuView;

@end

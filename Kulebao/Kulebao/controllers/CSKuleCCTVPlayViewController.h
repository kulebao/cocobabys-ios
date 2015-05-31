//
//  CSKuleCCTVPlayViewController.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-13.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@interface CSKuleCCTVPlayViewController : GLKViewController <GLKViewControllerDelegate>

@property (nonatomic, strong) NSDictionary* deviceMeta;
@property (nonatomic, assign) BOOL isTrail;

@end

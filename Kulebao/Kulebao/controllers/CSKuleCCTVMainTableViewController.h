//
//  CSKuleCCTVMainTableViewController.h
//  youlebao
//
//  Created by xin.c.wang on 14-8-12.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleVideoMember.h"

@interface CSKuleCCTVMainTableViewController : UITableViewController

@property (nonatomic, strong) CSKuleVideoMember* videoMember;
@property (nonatomic, assign) BOOL isTrail;

@end

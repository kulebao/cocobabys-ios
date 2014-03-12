//
//  CSKuleNewsDetailsViewController.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleNewsInfo.h"
#import "CSKuleAssignmentInfo.h"

@interface CSKuleNewsDetailsViewController : UIViewController

@property (nonatomic, strong) CSKuleNewsInfo* newsInfo;
@property (nonatomic, strong) CSKuleAssignmentInfo* assignmentInfo;

@end

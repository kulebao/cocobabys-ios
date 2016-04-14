//
//  CSKuleNewsDetailsViewController.h
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleNewsInfo.h"
#import "CSKuleAssignmentInfo.h"
#import "CSKuleCheckInOutLogInfo.h"

@interface CSKuleNewsDetailsViewController : UIViewController

@property (nonatomic, strong) CSKuleNewsInfo* newsInfo;
@property (nonatomic, strong) CSKuleAssignmentInfo* assignmentInfo;
@property (nonatomic, strong) CSKuleCheckInOutLogInfo* checkInOutLogInfo;

@end

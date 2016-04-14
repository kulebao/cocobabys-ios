//
//  CSNewsInfoReaderTableViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 10/10/15.
//  Copyright © 2015-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBNewsInfo;

@interface CSNewsInfoReaderTableViewController : UITableViewController

@property (nonatomic, strong) CBNewsInfo* newsInfo;
@property (nonatomic, strong) NSArray* readerList;

@end

//
//  CSNewsInfoReaderTableViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 10/10/15.
//  Copyright © 2015 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityNewsInfo.h"

@interface CSNewsInfoReaderTableViewController : UITableViewController

@property (nonatomic, strong) EntityNewsInfo* newsInfo;
@property (nonatomic, strong) NSArray* readerList;

@end

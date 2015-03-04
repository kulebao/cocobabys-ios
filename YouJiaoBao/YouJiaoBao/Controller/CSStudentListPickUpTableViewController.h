//
//  CSStudentListPickUpTableViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSStudentListPickUpTableViewController;

@protocol CSStudentListPickUpTableViewControllerDelegate <NSObject>

@optional
- (void)studentListPickUpTableViewController:(CSStudentListPickUpTableViewController*)ctrl
                                   didPickUp:(NSArray*)childList;

@end

@interface CSStudentListPickUpTableViewController : UITableViewController

@property (nonatomic, weak) id delegate;

@end

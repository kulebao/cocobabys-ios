//
//  CSKuleNewsTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 15/4/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleNewsInfo.h"

@interface CSKuleNewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labTag;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labPublisher;
@property (weak, nonatomic) IBOutlet UIImageView *imgAttachment;
@property (weak, nonatomic) IBOutlet UIButton *btnMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeading;

- (IBAction)onBtnMarkClicked:(id)sender;
- (void)loadNewsInfo:(CSKuleNewsInfo*)newsInfo;

- (void)refresh;

@end

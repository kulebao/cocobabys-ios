//
//  CSKuleNewsTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 15/4/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityNewsInfo.h"

@interface CSKuleNewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labTag;
@property (weak, nonatomic) IBOutlet UIImageView *imgTagBg;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labPublisher;
@property (weak, nonatomic) IBOutlet UIImageView *imgAttachment;
@property (weak, nonatomic) IBOutlet UIImageView *imgMarkBg;
@property (weak, nonatomic) IBOutlet UIButton *btnMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;

- (IBAction)onBtnMarkClicked:(id)sender;
- (void)loadNewsInfo:(EntityNewsInfo*)newsInfo;

- (void)refresh;

@end

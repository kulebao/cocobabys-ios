//
//  CSKuleNewsTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 15/4/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsTableViewCell.h"

@interface CSKuleNewsTableViewCell ()

@property (nonatomic, weak) CSKuleNewsInfo* newsInfo;

@end

@implementation CSKuleNewsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onBtnMarkClicked:(id)sender {
    [self.newsInfo markAsRead];
}

- (void)loadNewsInfo:(CSKuleNewsInfo*)newsInfo {
    self.newsInfo = newsInfo;
    self.newsInfo.delegate = self;
    
    [self refresh];
}

- (void)refresh {
    if ([self.newsInfo containsTag:@"作业"]) {
        self.labTag.text = @"亲子作业";
        self.labTag.backgroundColor = [UIColor orangeColor];
    }
    else {
        self.labTag.text = @"园内公告";
        self.labTag.backgroundColor = UIColorRGB(0x00, 0x66, 0xCC);
    }
    
    if (self.newsInfo.feedbackRequired) {
        if ([self.newsInfo isSendingMark]) {
            [self.btnMark setTitle:@"发送中" forState:UIControlStateNormal];
        }
        else {
            [self.btnMark setTitle:@"请回执" forState:UIControlStateNormal];
        }
        [self.btnMark setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnMark setBackgroundColor:[UIColor orangeColor]];
    }
    else {
        [self.btnMark setTitle:nil forState:UIControlStateNormal];
        [self.btnMark setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self.btnMark setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark - CSKuleNewsInfoDelegate
- (void)newsInfoDataUpdated:(CSKuleNewsInfo*)newsInfo {
    [self refresh];
}

@end

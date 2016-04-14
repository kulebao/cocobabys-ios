//
//  CSKuleNewsTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 15/4/12.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
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
    if (self.newsInfo.status == kNewsStatusUnknown
        || self.newsInfo.status == kNewsStatusUnread) {
        [self.newsInfo markAsRead];
    }
}

- (void)loadNewsInfo:(CSKuleNewsInfo*)newsInfo {
    self.newsInfo = newsInfo;
    self.newsInfo.delegate = self;
    
    [self refresh];
}

- (void)refresh {
    
    NSString* tagTitle = [self.newsInfo tagTitle];
    if ([tagTitle isEqualToString:@"亲子作业"]) {
        self.imgTagBg.image = [[UIImage imageNamed:@"v2-btn_亲子作业.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    }
    else {
        if (self.newsInfo.classId > 0) {
            tagTitle = @"班级通知";
            self.imgTagBg.image = [[UIImage imageNamed:@"v2-btn_班级通知.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        else {
            tagTitle = @"园内公告";
            self.imgTagBg.image = [[UIImage imageNamed:@"v2-btn_blue_s.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
    }
    self.labTag.text = tagTitle;
    
    if (self.newsInfo.feedbackRequired) {
        if (self.newsInfo.status == kNewsStatusMarking) {
            [self.btnMark setTitle:@"发送中" forState:UIControlStateNormal];
            self.imgMarkBg.image = [[UIImage imageNamed:@"v2-btn_请回执.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        else if (self.newsInfo.status == kNewsStatusRead) {
            [self.btnMark setTitle:@"已回执" forState:UIControlStateNormal];
            self.imgMarkBg.image = [[UIImage imageNamed:@"v2-btn_已回执.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        else {
            [self.btnMark setTitle:@"请回执" forState:UIControlStateNormal];
            self.imgMarkBg.image = [[UIImage imageNamed:@"v2-btn_请回执.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        [self.btnMark setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnMark.hidden = NO;
        self.imgMarkBg.hidden = NO;
    }
    else {
        [self.btnMark setTitle:nil forState:UIControlStateNormal];
        self.imgMarkBg.image = nil;
        self.btnMark.hidden = YES;
        self.imgMarkBg.hidden = YES;
    }
}


#pragma mark - CSKuleNewsInfoDelegate
- (void)newsInfoDataUpdated:(CSKuleNewsInfo*)newsInfo {
    [self refresh];
}

@end

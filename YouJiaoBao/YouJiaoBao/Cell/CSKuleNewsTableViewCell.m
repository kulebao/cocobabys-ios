//
//  CSKuleNewsTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 15/4/12.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsTableViewCell.h"
#import "CSAppDelegate.h"
#import "NSURL+CSKit.h"
#import "UIImageView+WebCache.h"
#import "NSDate+CSKit.h"
#import "UIImageView+AFNetworking.h"
#import "EntityClassInfoHelper.h"

@interface CSKuleNewsTableViewCell ()

@property (nonatomic, weak) EntityNewsInfo* newsInfo;

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

}

- (void)loadNewsInfo:(EntityNewsInfo*)newsInfo {
    self.newsInfo = newsInfo;
    
    self.labTitle.text = newsInfo.title;
    self.labContent.text = newsInfo.content;
    
    NSString* publiser = @"";
    if (newsInfo.classId.integerValue > 0) {
        EntityClassInfo* classInfo = [EntityClassInfoHelper queryEntityWithClassId:newsInfo.classId.integerValue];
        if (classInfo.name.length > 0) {
            publiser = classInfo.name;
        }
    }
    
    if (newsInfo.image.length > 0) {
        NSURL* qiniuImgUrl = [NSURL URLWithString:newsInfo.image];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/0/w/60/h/60"];
        [self.imgAttachment setImageWithURL:qiniuImgUrl
                              placeholderImage:[UIImage imageNamed:@"img-placeholder.png"]];
        self.imgAttachment.hidden = NO;
        self.iconWidth.constant = 60;
    }
    else {
        [self.imgAttachment cancelImageRequestOperation];
        self.imgAttachment.image = nil;
        self.imgAttachment.hidden = YES;
        self.iconWidth.constant = 0;
    }
    self.imgAttachment.clipsToBounds = YES;
    //cell.imgAttachment.layer.cornerRadius = 4;
    
    [self setNeedsUpdateConstraints];
    
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:(newsInfo.timestamp.longLongValue / 1000.0)];
    
    self.labPublisher.text = [NSString stringWithFormat:@"%@ %@", [timestamp timestampStringZhCN], publiser];
    
    [self refresh];
}

- (NSString*)tagTitle {
    NSString* tTitle = @"园内公告";
    NSRange range = [self.newsInfo.tags rangeOfString:@"作业"];
    if (range.length > 0) {
        tTitle = @"亲子作业";
    }
    else if(self.newsInfo.classId.integerValue > 0) {
        tTitle = @"班级通知";
    }
    
    return tTitle;
}

- (void)refresh {
    NSString* tagTitle = [self tagTitle];
    if ([tagTitle isEqualToString:@"亲子作业"]) {
        self.imgTagBg.image = [[UIImage imageNamed:@"v2-btn_亲子作业.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    }
    else {
        if (self.newsInfo.classId.integerValue > 0) {
            tagTitle = @"班级通知";
            self.imgTagBg.image = [[UIImage imageNamed:@"v2-btn_班级通知.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        else {
            tagTitle = @"园内公告";
            self.imgTagBg.image = [[UIImage imageNamed:@"v2-btn_blue_s.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
    }
    self.labTag.text = tagTitle;
    
    if (self.newsInfo.feedbackRequired.integerValue > 0) {
        [self.btnMark setTitle:@"需回执" forState:UIControlStateNormal];
        self.imgMarkBg.image = [[UIImage imageNamed:@"v2-btn_需回执.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        
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
- (void)newsInfoDataUpdated:(EntityNewsInfo*)newsInfo {
    [self refresh];
}

@end

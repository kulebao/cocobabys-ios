//
//  CSNoticeItemTableViewCell.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-9.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSNoticeItemTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CSUtils.h"

@interface CSNoticeItemTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labContent;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labPublisher;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumb;

@end

@implementation CSNoticeItemTableViewCell
@synthesize newsInfo = _newsInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.labPublisher.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNewsInfo:(EntityNewsInfo *)newsInfo {
    _newsInfo = newsInfo;
    
    if (_newsInfo) {
        self.labTitle.text = _newsInfo.title;
        self.labContent.text = _newsInfo.content;
        if (_newsInfo.image.length > 0) {
            [self.imgThumb sd_setImageWithURL:[NSURL URLWithString:_newsInfo.image]];
        }
        else {
            self.imgThumb.image = nil;
        }
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:(_newsInfo.timestamp.longLongValue / 1000.0)];
        self.labDate.text = [CSUtils stringFromDateStyle1:date];
    }
}

@end

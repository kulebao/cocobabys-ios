//
//  CSKuleChatingTableCell.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingTableCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@implementation CSKuleChatingTableCell
@synthesize msg = _msg;

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
    UIImageView* imgView = (UIImageView *)tap.view;
    
    MJPhoto* photo = [MJPhoto new];
    photo.url = [NSURL URLWithString:_msg.media.url];
    photo.srcImageView = imgView;
    
    MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
    browser.photos = @[photo];
    [browser show];
}

@end

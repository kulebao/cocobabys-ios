//
//  CSKuleCCTVItemTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-17.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleCCTVItemTableViewCell.h"

@implementation CSKuleCCTVItemTableViewCell

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
    self.imgBoxBg.image = [[UIImage imageNamed:@"v2-box_看宝宝.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

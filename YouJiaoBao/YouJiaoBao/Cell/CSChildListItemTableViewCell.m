//
//  CSChildListItemTableViewCell.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-6.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSChildListItemTableViewCell.h"

@implementation CSChildListItemTableViewCell

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

@end
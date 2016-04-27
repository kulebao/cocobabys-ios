//
//  CSSelectableTableViewCell.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-15.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSSelectableTableViewCell.h"

@implementation CSSelectableTableViewCell

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
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end

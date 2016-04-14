//
//  CSModuleCell.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-9-14.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSModuleCell.h"

@implementation CSModuleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)prepareForReuse {
    [super prepareForReuse];
    self.layer.shadowColor = [[UIColor clearColor] CGColor];
}

- (void)awakeFromNib
{
    // Initialization code
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowColor = [[UIColor clearColor] CGColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    // Configure the view for the selected state
    if (highlighted) {
        self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    }
    else {
        self.layer.shadowColor = [[UIColor clearColor] CGColor];
    }
}

@end

//
//  CSKuleCheckinLogTableViewCell.m
//  youlebao
//
//  Created by xin.c.wang on 15/5/4.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleCheckinLogTableViewCell.h"

@implementation CSKuleCheckinLogTableViewCell
@synthesize checkInOutInfo = _checkInOutInfo;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCheckInOutInfo:(CSKuleCheckInOutLogInfo *)checkInOutInfo {
    _checkInOutInfo = checkInOutInfo;
    // update cell
}

@end

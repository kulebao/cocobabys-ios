//
//  CBIMBanTableViewCell.m
//  YouJiaoBao
//
//  Created by WangXin on 1/25/16.
//  Copyright © 2016 Cocobabys. All rights reserved.
//

#import "CBIMBanTableViewCell.h"

@implementation CBIMBanTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onSwitchValueChanged:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti.im.ban.changed" object:self];
}

@end

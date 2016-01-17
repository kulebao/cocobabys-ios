//
//  CBIMGroupTeacherTableViewCell.m
//  youlebao
//
//  Created by WangXin on 12/16/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBIMGroupTeacherTableViewCell.h"
#import "CSAppDelegate.h"

@implementation CBIMGroupTeacherTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onBtnCallClickced:(id)sender {
    
    NSString* phone = [self.teacherInfo.phone trim];
    if (self.relationshipInfo) {
        phone = [self.relationshipInfo.parent.phone trim];
    }
    
    if (phone.length > 0) {
        BOOL ok = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]]];
        if (!ok && phone) {
            [gApp alert:@"拨打电话失败"];
        }
    }
}

@end

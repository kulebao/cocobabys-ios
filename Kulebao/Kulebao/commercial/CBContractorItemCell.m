//
//  CBContractorItemCell.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBContractorItemCell.h"
#import "UIImageView+WebCache.h"

@implementation CBContractorItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadItemData:(CBContractorData*)itemData {
    CBLogoData* logo = itemData.logos.firstObject;
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"v2-logo2.png"]];
    
    self.labTitle.text = itemData.title;
    self.labPhone.text = itemData.contact;
    self.labDetail.text = itemData.detail;
}

@end

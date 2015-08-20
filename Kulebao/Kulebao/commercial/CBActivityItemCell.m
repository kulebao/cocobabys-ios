//
//  CBActivityItemCell.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityItemCell.h"
#import "UIImageView+WebCache.h"

@implementation CBActivityItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadItemData:(CBActivityData*)itemData {
    CBLogoData* logo = itemData.logos.firstObject;
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:logo.url]];
    
    self.labTitle.text = itemData.title;
    self.labOriginal.text = itemData.price.origin;
    self.labDiscount.text = itemData.price.discounted;
    self.labDesc.text = itemData.detail;
}

@end

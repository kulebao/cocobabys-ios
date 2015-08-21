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
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"v2-logo2.png"]];
    
    self.labTitle.text = itemData.title;
    
    NSString* discounted = itemData.price.discounted;
    NSString* origin = itemData.price.origin;
    if (discounted.length == 0) {
        discounted = @"0";
    }
    if (origin.length == 0) {
        origin = @"0";
    }
    self.labOriginal.text = [NSString stringWithFormat:@"原价%@元", origin];
    self.labDiscount.text = [NSString stringWithFormat:@"幼乐宝用户专享 %@元", discounted];
    self.labDesc.text = itemData.detail;
}

@end

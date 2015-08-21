//
//  CBContractorItemCell.h
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBContractorData.h"

@interface CBContractorItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPhone;
@property (weak, nonatomic) IBOutlet UILabel *labDetail;

- (void)loadItemData:(CBContractorData*)itemData;

@end

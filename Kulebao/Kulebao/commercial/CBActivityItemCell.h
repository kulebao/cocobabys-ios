//
//  CBActivityItemCell.h
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBActivityData.h"

@interface CBActivityItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property (weak, nonatomic) IBOutlet UILabel *labDistance;

- (void)loadItemData:(CBActivityData*)itemData;

@end

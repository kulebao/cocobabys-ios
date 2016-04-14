//
//  CSNewsReaderTableViewCell.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 10/10/15.
//  Copyright © 2015-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSNewsReaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labStatus;
@property (weak, nonatomic) IBOutlet UIView *viewMask;

@end

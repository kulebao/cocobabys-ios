//
//  CSKuleCheckinLogTableViewCell.h
//  youlebao
//
//  Created by xin.c.wang on 15/5/4.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSKuleCheckInOutLogInfo.h"

@interface CSKuleCheckinLogTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labDesc;
@property (weak, nonatomic) IBOutlet UILabel *labDate;

@property (nonatomic, strong) CSKuleCheckInOutLogInfo* checkInOutInfo;

@end

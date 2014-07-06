//
//  CSDetailViewController.h
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-5.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

//
//  CBContractorMainViewController.h
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kContractorTypeOther = 0,       // 其他
    kContractorTypePhoto = 1,       // 亲子摄影
    kContractorTypeEducation = 2,   // 亲子教育
    kContractorTypeGame = 4,        // 亲子游乐
    kContractorTypeShop = 8         // 亲子购物
} ContractorType;

@interface CBContractorMainViewController : UIViewController

- (void)reloadData;

@end

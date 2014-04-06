//
//  CSKuleDatePickerViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-7.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleDatePickerViewController.h"

@interface CSKuleDatePickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datepicker;

@end

@implementation CSKuleDatePickerViewController
@synthesize date = _date;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_date) {
        _datepicker.date = _date;
    }
    
    _datepicker.maximumDate = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate*)date {
    return _datepicker.date;
}

- (void)setDate:(NSDate *)date {
    if ([self isViewLoaded]) {
        _datepicker.date = date;
    }
    else {
        _date = date;
    }
}

@end

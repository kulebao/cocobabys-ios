//
//  CSKuleNewsDetailsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsDetailsViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleNewsDetailsViewController ()

@end

@implementation CSKuleNewsDetailsViewController
@synthesize newsInfo = _newsInfo;

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
	// Do any additional setup after loading the view.
    [self customizeBackBarItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  CSKuleAboutViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleAboutViewController.h"

@interface CSKuleAboutViewController ()

- (IBAction)onBtnBackClicked:(id)sender;

@end

@implementation CSKuleAboutViewController

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

#pragma mark - UI Actions
- (IBAction)onBtnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

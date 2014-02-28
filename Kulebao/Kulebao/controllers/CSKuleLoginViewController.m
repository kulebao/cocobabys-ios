//
//  CSKuleLoginViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleLoginViewController.h"

@interface CSKuleLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labNotice;
@property (weak, nonatomic) IBOutlet UITextField *fieldPassword;
- (IBAction)onBtnLoginClicked:(id)sender;

@end

@implementation CSKuleLoginViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnLoginClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

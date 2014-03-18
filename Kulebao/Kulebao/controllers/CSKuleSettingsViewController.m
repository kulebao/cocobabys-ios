//
//  CSKuleSettingsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-2-28.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleSettingsViewController.h"
#import "AHAlertView.h"
#import "CSAppDelegate.h"

@interface CSKuleSettingsViewController ()
- (IBAction)onBtnCheckUpdatesClicked:(id)sender;
- (IBAction)onBtnFeedbackClicked:(id)sender;
- (IBAction)onBtnChangePswdClicked:(id)sender;
- (IBAction)onBtnSelectChildClicked:(id)sender;
- (IBAction)onBtnAboutUsClicked:(id)sender;
- (IBAction)onBtnLogoutClicked:(id)sender;

@end

@implementation CSKuleSettingsViewController

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
- (IBAction)onBtnCheckUpdatesClicked:(id)sender {
}

- (IBAction)onBtnFeedbackClicked:(id)sender {

}

- (IBAction)onBtnChangePswdClicked:(id)sender {
}

- (IBAction)onBtnSelectChildClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.selectChild" sender:nil];
}

- (IBAction)onBtnAboutUsClicked:(id)sender {
     [self performSegueWithIdentifier:@"segue.about" sender:nil];
}

- (IBAction)onBtnLogoutClicked:(id)sender {
    NSString *title = @"提示";
	NSString *message = @"确定要退出登录？退出后无法接收任何消息！";
	
	AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:@"取消" block:^{
	}];
    
	[alert addButtonWithTitle:@"确定" block:^{
        [self performSelector:@selector(doLogout) withObject:nil];
	}];
    
	[alert show];
}

#pragma mark - Private
- (void)doLogout {
    [gApp logout];
}

@end

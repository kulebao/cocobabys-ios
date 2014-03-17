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
    
    CSHttpClient* httpClient = [CSHttpClient clientWithBaseURL:[NSURL URLWithString:@"http://up.qiniu.com"]];
    
    UIImage* img = [UIImage imageNamed:@"icon-120.png"];
    NSData* da = UIImageJPEGRepresentation(img, 0.8);
    
    NSMutableURLRequest* req = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:da name:@"file" fileName:@"xxaaa.jpeg" mimeType:@"image/jpeg"];
        [formData appendPartWithFormData:[@"child_photo/93740362/1_1391836223533/1_1391836223533.jpg" dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
        
        [formData appendPartWithFormData:[@"vML8y91UgErLsWX2Lzk6dkD6tZqgGGyw5-Fyv17_:gpOIO6JtFC8wGqwjJo7tfccc_qI=:eyJzY29wZSI6ImNvY29iYWJ5czpjaGlsZF9waG90by85Mzc0MDM2Mi8xXzEzOTE4MzYyMjM1MzMvMV8xMzkxODM2MjIzNTMzLmpwZyIsInJldHVybkJvZHkiOiJ7XCJuYW1lXCI6ICQoZm5hbWUpLCBcInNpemVcIjogJChmc2l6ZSksXCJoYXNoXCI6ICQoZXRhZyl9IiwiZGVhZGxpbmUiOjEzOTQ1MjU1Nzl9" dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    }];
    
    AFJSONRequestOperation* oper = [AFJSONRequestOperation CSJSONRequestOperationWithRequest:req success:^(NSURLRequest *request, id dataJson) {
        CSLog(@"success");
    } failure:^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure");
    }];
    
    [httpClient enqueueHTTPRequestOperation:oper];
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

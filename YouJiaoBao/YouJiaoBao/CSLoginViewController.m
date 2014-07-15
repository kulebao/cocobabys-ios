//
//  CSLoginViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSLoginViewController.h"
#import "CSHttpClient.h"

@interface CSLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;

- (IBAction)onBtnLoginClicked:(id)sender;

@end

@implementation CSLoginViewController

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnLoginClicked:(id)sender {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    [http opLoginWithUsername:@"wx0011" password:@"18782242007"];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti.login.success" object:nil userInfo:nil];
}
@end

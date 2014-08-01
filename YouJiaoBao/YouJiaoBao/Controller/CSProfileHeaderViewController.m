//
//  CSProfileHeaderViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSProfileHeaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CSEngine.h"

@interface CSProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labUsername;
@property (weak, nonatomic) IBOutlet UILabel *labNick;

@end

@implementation CSProfileHeaderViewController

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
    
    self.imgPortrait.layer.cornerRadius = 32.0;
    self.imgPortrait.clipsToBounds = YES;
    self.imgPortrait.layer.borderWidth = 2;
    self.imgPortrait.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CSEngine* engine = [CSEngine sharedInstance];
    if (engine.loginInfo) {
        self.labUsername.text = [NSString stringWithFormat:@"登录名: %@", engine.loginInfo.loginName];
        self.labNick.text = [NSString stringWithFormat:@"昵称: %@", engine.loginInfo.name];
    }
    else {
        self.labUsername.text = nil;
        self.labNick.text = nil;
    }
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

@end

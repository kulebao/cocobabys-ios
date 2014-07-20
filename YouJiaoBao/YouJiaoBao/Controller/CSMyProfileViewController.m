//
//  CSMyProfileViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSMyProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CSEngine.h"

@interface CSMyProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labLoginName;
@property (weak, nonatomic) IBOutlet UILabel *labNick;

@end

@implementation CSMyProfileViewController

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
    CSEngine* sharedEngine = [CSEngine sharedInstance];
    
    [self.imgPortrait setImageWithURL:[NSURL URLWithString:sharedEngine.loginInfo.portrait]
                     placeholderImage:[UIImage imageNamed:@"logo-gray-big"]];
    
    self.labLoginName.text = sharedEngine.loginInfo.loginName;
    self.labNick.text = sharedEngine.loginInfo.name;
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

@end

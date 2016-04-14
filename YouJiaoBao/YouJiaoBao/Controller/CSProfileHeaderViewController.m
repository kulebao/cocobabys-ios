//
//  CSProfileHeaderViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSProfileHeaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CSEngine.h"
#import "UIImageView+WebCache.h"

@interface CSProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labUsername;
- (IBAction)onBtnPhotoClicked:(id)sender;

@end

@implementation CSProfileHeaderViewController
@synthesize delegate = _delegate;
@synthesize moreDetails;

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
    self.imgPortrait.clipsToBounds = YES;
    self.imgPortrait.layer.borderWidth = 1;
    self.imgPortrait.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imgPortrait.layer.cornerRadius = self.imgPortrait.bounds.size.width/2;
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    if (session.loginInfo) {
        self.labUsername.text = [NSString stringWithFormat:@"登录名: %@", session.loginInfo.login_name];
        
        if (self.moreDetails) {
            self.labUsername.text = [NSString stringWithFormat:@"登录名: %@\n昵称: %@", session.loginInfo.login_name, session.loginInfo.name];
        }
        else {
            self.labUsername.text = session.loginInfo.name;
        }
        
        [self.imgPortrait sd_setImageWithURL:[NSURL URLWithString:session.loginInfo.portrait]
                            placeholderImage:[UIImage imageNamed:@"chat_head_icon.gif"]];
    }
    else {
        self.labUsername.text = @"未登录";
        self.imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.gif"];
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

- (IBAction)onBtnPhotoClicked:(id)sender {
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    if (session.loginInfo && [_delegate respondsToSelector:@selector(profileHeaderViewControllerWillUpdateProfile:)]) {
        [_delegate profileHeaderViewControllerWillUpdateProfile:self];
    }
}

@end

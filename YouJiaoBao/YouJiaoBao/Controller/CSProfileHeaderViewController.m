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

- (void)reloadData {
    
    CSEngine* engine = [CSEngine sharedInstance];
    if (engine.loginInfo) {
        self.labUsername.text = [NSString stringWithFormat:@"登录名: %@", engine.loginInfo.loginName];
        
        if (self.moreDetails) {
            self.labUsername.text = [NSString stringWithFormat:@"登录名: %@\n昵称: %@", engine.loginInfo.loginName, engine.loginInfo.name];
        }
        else {
            self.labUsername.text = engine.loginInfo.name;
        }
        
        [self.imgPortrait sd_setImageWithURL:[NSURL URLWithString:engine.loginInfo.portrait]
                            placeholderImage:[UIImage imageNamed:@"chat_head_icon.gif"]];
    }
    else {
        self.labUsername.text = @"未登录";
        self.imgPortrait.image = [UIImage imageNamed:@"chat_head_icon.gif"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self reloadData];
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
    CSEngine* engine = [CSEngine sharedInstance];
    if (engine.loginInfo && [_delegate respondsToSelector:@selector(profileHeaderViewControllerWillUpdateProfile:)]) {
        [_delegate profileHeaderViewControllerWillUpdateProfile:self];
    }
}

@end

//
//  CSChildProfileHeaderViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSChildProfileHeaderViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface CSChildProfileHeaderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIButton *btnAssessments;
@property (weak, nonatomic) IBOutlet UIButton *btnSession;
- (IBAction)onBtnSessionClicked:(id)sender;
- (IBAction)onBtnAssessmentsClicked:(id)sender;

@end

@implementation CSChildProfileHeaderViewController
@synthesize childInfo = _childInfo;

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
    
    self.imgPortrait.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imgPortrait.layer.borderWidth = 2;
    self.imgPortrait.clipsToBounds = YES;
    self.imgPortrait.layer.cornerRadius = 40.0;
    
    [self.imgPortrait setImageWithURL:[NSURL URLWithString:self.childInfo.portrait]
                     placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    
    self.labName.text = self.childInfo.nick;
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

- (IBAction)onBtnSessionClicked:(id)sender {
}

- (IBAction)onBtnAssessmentsClicked:(id)sender {
}
@end
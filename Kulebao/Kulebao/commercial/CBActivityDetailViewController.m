//
//  CBActivityDetailViewController.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface CBActivityDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property (weak, nonatomic) IBOutlet UILabel *labPhone;
@property (weak, nonatomic) IBOutlet UILabel *labAddress;
@property (weak, nonatomic) IBOutlet UITextView *textDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnJoin;
- (IBAction)onBtnCallClicked:(id)sender;
- (IBAction)onBtnNaviClicked:(id)sender;
- (IBAction)onBtnJoinClicked:(id)sender;

@end

@implementation CBActivityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setActivityData:(CBActivityData *)activityData {
    _activityData = activityData;
    
    if ([self isViewLoaded]) {
        [self reloadData];
    }
}

- (void)reloadData {
    CBLogoData* logo = self.activityData.logos.firstObject;
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"v2-logo2.png"]];
    self.labTitle.text = self.activityData.title;
    
    NSString* discounted = self.activityData.price.discounted;
    NSString* origin = self.activityData.price.origin;
    if (discounted.length == 0) {
        discounted = @"0";
    }
    if (origin.length == 0) {
        origin = @"0";
    }
    self.labPrice.text = [NSString stringWithFormat:@"%@ %@", discounted, origin];
    self.labPhone.text = self.activityData.contact;
    self.labAddress.text = self.activityData.address;
    self.textDetail.text = self.activityData.detail;
}

- (IBAction)onBtnCallClicked:(id)sender {
}

- (IBAction)onBtnNaviClicked:(id)sender {
}

- (IBAction)onBtnJoinClicked:(id)sender {
}
@end

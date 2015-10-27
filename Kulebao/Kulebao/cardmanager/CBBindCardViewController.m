//
//  CBBindCardViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/27/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBBindCardViewController.h"
#import "CSAppDelegate.h"

@interface CBBindCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fieldCardNo;
@property (weak, nonatomic) IBOutlet UIButton *btnBindCard;
- (IBAction)onBtnBindCardClicked:(id)sender;

@end

@implementation CBBindCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    self.fieldCardNo.text = gApp.engine.currentRelationship.card;
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

- (IBAction)onBtnBindCardClicked:(id)sender {
    [self.fieldCardNo resignFirstResponder];
}

@end

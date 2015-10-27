//
//  CBAddFamilyViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/27/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBAddFamilyViewController.h"
#import "CSAppDelegate.h"

@interface CBAddFamilyViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fieldPhone;
@property (weak, nonatomic) IBOutlet UITextField *fieldPasscode;
@property (weak, nonatomic) IBOutlet UIButton *btnGetPasscode;
@property (weak, nonatomic) IBOutlet UITextField *fieldName;
@property (weak, nonatomic) IBOutlet UITextField *fieldRelationship;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
- (IBAction)onBtnGetPasscodeClicked:(id)sender;
- (IBAction)onBtnInviteClicked:(id)sender;

@end

@implementation CBAddFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
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

- (IBAction)onBtnGetPasscodeClicked:(id)sender {
    [self closeKeyboard];
}

- (IBAction)onBtnInviteClicked:(id)sender {
    [self closeKeyboard];
}

- (void)closeKeyboard {
    [self.fieldName resignFirstResponder];
    [self.fieldPasscode resignFirstResponder];
    [self.fieldPhone resignFirstResponder];
    [self.fieldRelationship resignFirstResponder];
}

@end

//
//  CBBindCardViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/27/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBBindCardViewController.h"
#import "CSAppDelegate.h"
#import "NSString+CSKit.h"

typedef enum : NSUInteger {
    kBindCardAlreadyUsed = 6,
    kBindCardDuplicated = 3,
    kBindCardInvalid = 4,
    kBindCardSuccess = 0
} BindCardError;

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
    
    if ([gApp.engine.currentRelationship.card isValidCardNum]) {
        self.fieldCardNo.text = gApp.engine.currentRelationship.card;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self.fieldCardNo becomeFirstResponder];
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
    
    NSString* cardNum = [self.fieldCardNo.text trim];
    self.fieldCardNo.text = cardNum;
    
    if ([cardNum isValidCardNum]) {
        [gApp waitingAlert:@"绑定中，请稍候..."];
        [gApp.engine reqBindCardOfKindergarten:gApp.engine.loginInfo.schoolId
                                   withCardNum:cardNum
                                       success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                           NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                                           if (error_code == 0) {
                                               CSKuleRelationshipInfo* relationship = [CSKuleInterpreter decodeRelationshipInfo:dataJson];
                                               if (gApp.engine.currentRelationship.uid == relationship.uid) {
                                                   gApp.engine.currentRelationship.card = relationship.card;
                                               }
                                               
                                               [self.navigationController popViewControllerAnimated:YES];
                                               
                                               [gApp alert:@"绑定成功"];
                                           }
                                           else if (kBindCardInvalid == error_code) {
                                               [gApp alert:@"绑定失败,卡未授权"];
                                           }
                                           else if (kBindCardAlreadyUsed == error_code || kBindCardDuplicated == error_code) {
                                               [gApp alert:@"绑定失败，卡号已被其他家长绑定"];
                                           }
                                           else {
                                               [gApp alert:@"绑定失败"];
                                           }
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           [gApp alert:@"绑定失败"];
                                       }];
    }
    else {
        [gApp alert:@"卡号格式有误，请重新输入"];
    }
}

@end

//
//  CBIMChatViewController.m
//  youlebao
//
//  Created by WangXin on 12/3/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBIMChatViewController.h"
#import "CBChatViewSettingsViewController.h"
#import "CBIMDataSource.h"

@interface CBIMChatViewController ()

@end

@implementation CBIMChatViewController

- (void)viewDidLoad {
    [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.conversationType == ConversationType_GROUP) {
        [self customizeOkBarItemWithTarget:self action:@selector(onRightNaviItemClicked:) text:@"群组成员"];
    }
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

- (void)onRightNaviItemClicked:(id)sender {
#if 1
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"IM" bundle:nil];
    CBChatViewSettingsViewController* ctrl = [storyboard instantiateViewControllerWithIdentifier:@"CBChatViewSettingsViewController"];
    ctrl.targetId = self.targetId;
    [self.navigationController pushViewController:ctrl animated:YES];
#else
    RCConversationSettingTableViewController* ctrl = [[RCConversationSettingTableViewController alloc] initWithStyle:UITableViewStylePlain];
    ctrl.navigationItem.title = @"会话设置";
    [self.navigationController pushViewController:ctrl animated:YES];
#endif
}

- (void)didTapCellPortrait:(NSString *)userId {
    [[CBIMDataSource sharedInstance] getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
        CBIMChatViewController *conversationVC = [[CBIMChatViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = userId;
        conversationVC.userName = userInfo.name;
        conversationVC.title = userInfo.name;
        
        [self.navigationController pushViewController:conversationVC animated:YES];
    }];
    
}

@end

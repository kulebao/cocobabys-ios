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

@interface CBIMChatViewController ()  <CBChatViewSettingsViewControllerDelegate>

@end

@implementation CBIMChatViewController

- (void)viewDidLoad {
    [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.conversationType == ConversationType_GROUP) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v2-im-groupmembers"]
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(onRightNaviItemClicked:)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)onRightNaviItemClicked:(id)sender {
#if 1
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"IM" bundle:nil];
    CBChatViewSettingsViewController* ctrl = [storyboard instantiateViewControllerWithIdentifier:@"CBChatViewSettingsViewController"];
    ctrl.targetId = self.targetId;
    ctrl.delegate = self;
    [self.navigationController pushViewController:ctrl animated:YES];
#else
    RCConversationSettingTableViewController* ctrl = [[RCConversationSettingTableViewController alloc] initWithStyle:UITableViewStylePlain];
    ctrl.navigationItem.title = @"会话设置";
    [self.navigationController pushViewController:ctrl animated:YES];
#endif
}

- (void)didTapCellPortrait:(NSString *)userId {
    if (self.conversationType == ConversationType_GROUP
        || self.conversationType == ConversationType_DISCUSSION
        || self.conversationType == ConversationType_CHATROOM) {
        
        RCUserInfo* me = [[RCIMClient sharedRCIMClient] currentUserInfo];
        if ([me.userId isEqualToString:userId]
            ||[userId isEqualToString:@"im_system_admin"]) {
            
        }
        else {
            [[CBIMDataSource sharedInstance] getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
                CBIMChatViewController *conversationVC = [[CBIMChatViewController alloc]init];
                conversationVC.conversationType = ConversationType_PRIVATE;
                conversationVC.targetId = userId;
                conversationVC.title = userInfo.name;
                
                [self.navigationController pushViewController:conversationVC animated:YES];
            }];
        }
    }
}

#pragma mark - CBChatViewSettingsViewControllerDelegate
- (void)chatViewSettingsViewControllerDidClearMsg:(CBChatViewSettingsViewController*)ctrl {
    [self.conversationDataRepository removeAllObjects];
    [self.conversationMessageCollectionView reloadData];
}

@end

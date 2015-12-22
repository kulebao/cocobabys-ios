//
//  CBChatListViewController.m
//  youlebao
//
//  Created by WangXin on 12/3/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBIMChatListViewController.h"
#import "CSAppDelegate.h"
#import "CBIMChatViewController.h"

@interface CBIMChatListViewController ()

@end

@implementation CBIMChatListViewController

- (void)viewDidLoad {
    [self setConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationItem.title = gApp.engine.currentRelationship.child.className;
    self.navigationItem.title = @"会话列表";
    
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

//重载函数，onSelectedTableRow 是选择会话列表之后的事件，该接口开放是为了便于您自定义跳转事件。在快速集成过程中，您只需要复制这段代码。
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    CBIMChatViewController *conversationVC = [[CBIMChatViewController alloc]init];
    conversationVC.conversationType =model.conversationType;
    conversationVC.targetId = model.targetId;
    conversationVC.userName =model.conversationTitle;
    conversationVC.title = model.conversationTitle;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

/**
 *  将要加载table数据
 *
 *  @param dataSource 数据源数组
 *
 *  @return 数据源数组，可以添加自己定义的数据源item
 */
- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource {

    NSMutableArray* newDataSource = [NSMutableArray array];
    for (RCConversationModel* m in dataSource) {
        if (m.conversationType == ConversationType_PRIVATE) {
            [newDataSource addObject:m];
        }
        else if (m.conversationType == ConversationType_GROUP) {
            [newDataSource addObject:m];
        }
        else {
            [newDataSource addObject:m];
        }
    }
    
    return newDataSource;
}

@end

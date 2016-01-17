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
#import "UIActionSheet+BlocksKit.h"
#import "CBIMGroupMembersViewController.h"
#import "CSEngine.h"
#import "EntityClassInfoHelper.h"

@interface CBIMChatListViewController ()

@end

@implementation CBIMChatListViewController

- (void)viewDidLoad {
    [self setConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationItem.title = gApp.engine.currentRelationship.child.className;
    self.navigationItem.title = @"会话列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v2-im-groupmembers"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(onRightNaviItemClicked:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRightNaviItemClicked:(id)sender {
    UIActionSheet* sheet = [UIActionSheet bk_actionSheetWithTitle:@"请选择一个班级"];
    
    CSEngine* engine = [CSEngine sharedInstance];
    
    NSFetchedResultsController* fr = [EntityClassInfoHelper frClassesWithEmployee:engine.loginInfo.uid ofKindergarten:engine.loginInfo.schoolId.integerValue];
    
    if ([fr performFetch:nil]) {
        
        for (EntityClassInfo* clasInfo in fr.fetchedObjects) {
            [sheet bk_addButtonWithTitle:clasInfo.name handler:^{
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"IM" bundle:nil];
                
                NSString* targetId = [NSString stringWithFormat:@"%@_%@", clasInfo.schoolId, clasInfo.classId];
                CBIMGroupMembersViewController* ctrl = [storyboard instantiateViewControllerWithIdentifier:@"CBIMGroupMembersViewController"];
                ctrl.targetId = targetId;
                [self.navigationController pushViewController:ctrl animated:YES];
            }];
        }
        
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        
        [sheet showInView:self.view];
    }
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
    
    NSMutableSet* targerIdSet = [NSMutableSet set];
    
    CSEngine* engine = [CSEngine sharedInstance];
    
    NSFetchedResultsController* fr = [EntityClassInfoHelper frClassesWithEmployee:engine.loginInfo.uid ofKindergarten:engine.loginInfo.schoolId.integerValue];
    
    if ([fr performFetch:nil]) {
        for (EntityClassInfo* clasInfo in fr.fetchedObjects) {
            if (clasInfo.schoolId.integerValue>0 && clasInfo.classId.integerValue>0) {
                NSString* targetId = [NSString stringWithFormat:@"%@_%@", clasInfo.schoolId, clasInfo.classId];
                [targerIdSet addObject:targetId];
            }
        }
    }
    
    NSMutableArray* newDataSource = [NSMutableArray array];
    for (RCConversationModel* m in dataSource) {
        if (m.conversationType == ConversationType_PRIVATE) {
            [newDataSource addObject:m];
        }
        else if (m.conversationType == ConversationType_GROUP) {
            [newDataSource addObject:m];
            m.isTop = YES;
        }
        else {
            [newDataSource addObject:m];
        }
        
        [targerIdSet removeObject:m.targetId];
    }
    
    for (NSString* targetId in targerIdSet) {
        RCConversation* conv = [[RCConversation alloc] init];
        conv.targetId = targetId;
        conv.conversationType = ConversationType_GROUP;
        RCConversationModel* newModel = [[RCConversationModel alloc] init:RC_CONVERSATION_MODEL_TYPE_NORMAL conversation:conv extend:nil];
        [newDataSource addObject:newModel];
        newModel.receivedTime = [[NSDate date] timeIntervalSince1970]*1000;
        newModel.sentTime = [[NSDate date] timeIntervalSince1970]*1000;
        newModel.isTop = YES;
        //
        //        RCIMClient* im = [RCIMClient sharedRCIMClient];
        //        RCTextMessage* msgContent = [RCTextMessage new];
        //        msgContent.content = @"点击开始会话";
        //        [im insertMessage:ConversationType_GROUP targetId:targetId senderUserId:@"im_system_admin" sendStatus:SentStatus_RECEIVED content:msgContent];
        
        RCInformationNotificationMessage* warningMessage = [RCInformationNotificationMessage notificationWithMessage:@"点击开始会话" extra:nil];
        RCMessage* insertMessage =[[RCMessage alloc] initWithType:ConversationType_GROUP
                                                         targetId:targetId
                                                        direction:MessageDirection_SEND
                                                        messageId:-1
                                                          content:warningMessage];
        
        
        newModel.lastestMessage = insertMessage.content;
        newModel.lastestMessageId = -1;
    }
    
    return newDataSource;
}

@end

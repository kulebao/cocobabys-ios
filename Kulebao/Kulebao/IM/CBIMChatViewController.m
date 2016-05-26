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
#import "CBHttpClient.h"
#import "CBIMBanInfoData.h"
#import <objc/runtime.h>
#import "CSAppDelegate.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

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
        
        
        [self reloadIMBindInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageCotent {
    id msg = messageCotent;
    if (self.conversationType == ConversationType_GROUP) {
        BOOL band = [[CBIMDataSource sharedInstance] isBandInGroup:self.targetId];
        
        if (band && [msg respondsToSelector:@selector(setExtra:)]) {
            CSLog(@"sent forbidden_msg.");
            [msg setExtra:@"forbidden_msg"];
        }
    }
    
    return msg;
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

- (void)didTapMessageCell:(RCMessageModel *)model {
    RCMessageContent* msgContent = model.content;
    if ([msgContent isKindOfClass:[RCImageMessage class]]) {
        MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
        NSMutableArray* photoList = [NSMutableArray array];
        browser.currentPhotoIndex = 0;
        browser.hidenSaveBtn = NO;
        
        NSInteger index = [self.conversationDataRepository indexOfObject:model];
        RCImageMessageCell* cell = (RCImageMessageCell*)[self.conversationMessageCollectionView
                                                         cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        for (RCMessageModel* m in self.conversationDataRepository) {
            if ([m.content isKindOfClass:[RCImageMessage class]]) {
                RCImageMessage* imgMsg = (RCImageMessage*)m.content;
                
                MJPhoto* photo = [MJPhoto new];
                photo.url = [NSURL URLWithString:imgMsg.imageUrl];
                photo.srcImageView = cell.pictureView;
                if ([m isEqual:model]) {
                    browser.currentPhotoIndex = photoList.count;
                }
                
                [photoList addObject:photo];
            }
            
            ++index;
        }
        
        browser.photos = photoList;
        browser.hidenToolbar = NO;
        browser.hidenSaveBtn = YES;
        
        [browser show];
    }
    else {
        [super didTapMessageCell:model];
    }
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model
                         inView:(UIView *)view {
    
    RCMessage* msg = [[RCIMClient sharedRCIMClient] getMessage:model.messageId];
    CSLog(@"GET MSGUID:%@", msg.messageUId);
    
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = YES;
    //self.longPressSelectedModel = model;
    
    CGRect rect = [self.view convertRect:view.frame fromView:view.superview];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    objc_setAssociatedObject(menu, "msg", msg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(menu, "msgModel", model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIMenuItem *copyItem = [[UIMenuItem alloc]
                            initWithTitle:NSLocalizedStringFromTable(@"Copy", @"RongCloudKit", nil)
                            action:@selector(onCopyMessage:)];
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc]
                              initWithTitle:NSLocalizedStringFromTable(@"Delete", @"RongCloudKit", nil)
                              action:@selector(onDeleteMessage:)];
    
    NSMutableArray* menuItems = [NSMutableArray array];
    
    if ([model.content isKindOfClass:[RCTextMessage class]]) {
        [menuItems addObjectsFromArray:@[copyItem, deleteItem]];
    } else {
        [menuItems addObject:deleteItem];
    }
    
    if ([model.senderUserId isEqualToString:[[[RCIM sharedRCIM] currentUserInfo] userId]]) {
        UIMenuItem *hideItem = [[UIMenuItem alloc]
                                  initWithTitle:@"撤回"
                                  action:@selector(onCallbackMessage:)];
        [menuItems addObject:hideItem];
    }
    
    [menu setMenuItems:menuItems];
    
    [menu setTargetRect:rect inView:self.view];
    [menu setMenuVisible:YES animated:YES];
}

- (void)onCopyMessage:(id)sender {
    RCMessage* msg = objc_getAssociatedObject(sender, "msg");
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if ([msg.content respondsToSelector:@selector(content)]) {
        pasteboard.string = [(id)msg.content content];
    }
}

- (void)onDeleteMessage:(id)sender {
    RCMessageModel* msgModel = objc_getAssociatedObject(sender, "msgModel");
    if (msgModel) {
        [self deleteMessage:msgModel];
    }
}

- (void)onCallbackMessage:(id)sender {
    RCMessage* msg = objc_getAssociatedObject(sender, "msg");
//    if (msgModel) {
//        [self deleteMessage:msgModel];
//    }
    CBHttpClient* http = [CBHttpClient sharedInstance];
    
    if (self.conversationType == ConversationType_GROUP) {
        [http reqHideGroupMsgs:@[msg.messageUId]
                inKindergarten:gApp.engine.loginInfo.schoolId
                   withClassId:gApp.engine.currentRelationship.child.classId
                       success:^(NSURLSessionDataTask *task, id dataJson) {
                           CSLog(@"success %@", dataJson);
                       } failure:^(NSURLSessionDataTask *task, NSError *error) {
                           CSLog(@"failure %@", error);
                       }];
    }
    else {
        [http reqHidePrivateMsgs:@[msg.messageUId]
                  inKindergarten:gApp.engine.loginInfo.schoolId
                    withTargetId:[[[RCIM sharedRCIM] currentUserInfo] userId]
                         success:^(NSURLSessionDataTask *task, id dataJson) {
                             CSLog(@"success %@", dataJson);
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             CSLog(@"failure %@", error);
                         }];
    }
}

#pragma mark - CBChatViewSettingsViewControllerDelegate
- (void)chatViewSettingsViewControllerDidClearMsg:(CBChatViewSettingsViewController*)ctrl {
    [self.conversationDataRepository removeAllObjects];
    [self.conversationMessageCollectionView reloadData];
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message {
    RCMessage* msg = message;
    
    if ([message.content respondsToSelector:@selector(extra)]
        && ![message.senderUserId isEqualToString:[[[RCIM sharedRCIM] currentUserInfo] userId]]) {
        NSString* extra = [(id)message.content extra];
        if ([extra containsString:@"forbidden_msg"]) {
            msg = nil;
            CSLog(@"hidden forbidden_msg cell");
        }
    }
    else if ([msg.extra containsString:@"forbidden_msg"]) {
        msg = nil;
        CSLog(@"hidden hidemsg cell");
    }
    
    return msg;
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize sz = [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    RCMessageModel* msgModel = [self.conversationDataRepository objectAtIndex:indexPath.row];
    id msgContent = msgModel.content;
    NSString* extra = [msgContent extra];
    if (extra.length > 0) {
        sz = CGSizeZero;
    }
    
    return sz;
}

#pragma mark - 
- (void)reloadIMBindInfo {
    NSString* group_school_id = nil;
    NSString* group_class_id = nil;
    
    NSArray* components = [self.targetId componentsSeparatedByString:@"_"];
    if (components.count == 2) {
        group_school_id = components[0];
        group_class_id = components[1];
        
        CBHttpClient* http = [CBHttpClient sharedInstance];
        
        [http reqGetIMBandInfoOfKindergarten:group_school_id.integerValue
                                 withClassId:group_class_id.integerValue success:^(NSURLSessionDataTask *task, id dataJson) {
                                     if ([dataJson isKindOfClass:[NSArray class]]) {
                                         NSMutableArray* banInfoList = [NSMutableArray array];
                                         for (NSDictionary* info in dataJson) {
                                             CBIMBanInfoData* obj = [CBIMBanInfoData instanceWithDictionary:info];
                                             if (obj) {
                                                 [banInfoList addObject:obj];
                                             }
                                         }
                                         [[[CBIMDataSource sharedInstance] banList] setObject:banInfoList
                                                                                       forKey:self.targetId];
                                     }
                                     else {
                                         [[[CBIMDataSource sharedInstance] banList] setObject:@[] forKey:self.targetId];
                                     }
                                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     
                                     
                                 }];
    }
}

@end

//
//  CBChatViewSettingsViewController.m
//  youlebao
//
//  Created by WangXin on 12/7/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBChatViewSettingsViewController.h"
#import "CBIMGroupMembersViewController.h"
#import "CSAppDelegate.h"
#import "CBRelationshipInfo.h"
#import "CBIMDataSource.h"
#import "UIImageView+WebCache.h"
#import "CBIMSettingsModel.h"

@interface CBChatViewSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labSchoolName;
@property (weak, nonatomic) IBOutlet UILabel *labClassName;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UISwitch *switchDistribu;
- (IBAction)onSwitchDistribuValueChanged:(id)sender;

@end

@implementation CBChatViewSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    self.labSchoolName.text = [gApp.engine.loginInfo.schoolName trim];
    
    CBIMDataSource* imDS = [CBIMDataSource sharedInstance];
    
    [imDS getGroupInfoWithGroupId:self.targetId completion:^(RCGroup *groupInfo) {
        self.labClassName.text = SAFE_STRING(groupInfo.groupName);
        [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:groupInfo.portraitUri]
                        placeholderImage:[UIImage imageNamed:@"v2-im-group"]];
    }];
    
    CBIMSettingsModel* model = [CBIMSettingsModel sharedInstance];
    self.switchDistribu.on = [model getGroupDistrubEnabled:self.targetId];
    
    RCIMClient* im = [RCIMClient sharedRCIMClient];
    [im getConversationNotificationStatus:ConversationType_GROUP
                                 targetId:self.targetId
                                  success:^(RCConversationNotificationStatus nStatus) {
                                      self.switchDistribu.on = (DO_NOT_DISTURB == nStatus);
                                  } error:^(RCErrorCode status) {
                                      
                                  }];
    
    [self reloadUI];
}

- (void)reloadUI {

}

#if 0
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
#endif
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here, for example:
    // Create the next view controller.
    //<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
    if(0 == indexPath.section && 3 == indexPath.row) {
        //清除缓存
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"清空群组消息？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = 1011;
        [alertView show];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.im.groupmembers"]) {
        CBIMGroupMembersViewController* ctrl = segue.destinationViewController;
        ctrl.targetId = self.targetId;
    }
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1011) {
        [self clearCache];
    }
}

//清理缓存
-(void) clearCache {
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       
#if 0
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess)
                                              withObject:nil waitUntilDone:YES];
#else
      
                       RCIMClient* im = [RCIMClient sharedRCIMClient];
                       [im clearMessages:ConversationType_GROUP targetId:self.targetId];
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess)
                                              withObject:nil
                                           waitUntilDone:YES];
                        
#endif
                   });
}

-(void)clearCacheSuccess {
    [gApp alert:@"清除成功"];
    if ([self.delegate respondsToSelector:@selector(chatViewSettingsViewControllerDidClearMsg:)]) {
        [self.delegate chatViewSettingsViewControllerDidClearMsg:self];
    }
}

- (IBAction)onSwitchDistribuValueChanged:(id)sender {
    CBIMSettingsModel* model = [CBIMSettingsModel sharedInstance];
    [model setGroup:self.targetId disturb:self.switchDistribu.on];
    
    RCIMClient* im = [RCIMClient sharedRCIMClient];
    [im setConversationNotificationStatus:ConversationType_GROUP
                                 targetId:self.targetId
                                isBlocked:self.switchDistribu.on
                                  success:^(RCConversationNotificationStatus nStatus) {
                                  } error:^(RCErrorCode status) {
                                      
                                  }];
}

@end

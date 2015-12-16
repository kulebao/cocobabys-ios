//
//  CBIMGroupMembersViewController.m
//  youlebao
//
//  Created by WangXin on 12/14/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBIMGroupMembersViewController.h"
#import "CBIMDataSource.h"
#import "CBTeacherInfo.h"
#import "CBRelationshipInfo.h"
#import "CSAppDelegate.h"
#import "CBHttpClient.h"
#import "CBIMGroupTeacherTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CBIMChatViewController.h"

@interface CBIMGroupMembersViewController () {
    NSInteger _schoolId;
    NSInteger _classId;
    UIImage* _defaultPortrait;
    UIImageView* _imgvCall;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segMemberType;
@property (nonatomic, strong) NSMutableArray* teacherList;
@property (nonatomic, strong) NSMutableArray* relationshipGroupList;

- (IBAction)onSegMemberTypeValueChanged:(id)sender;

@end

@implementation CBIMGroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString* imgBundlePath = [[NSBundle mainBundle] pathForResource:@"RongCloud" ofType:@"bundle"];
    NSString* imgPath = [[NSBundle bundleWithPath:imgBundlePath] pathForResource:@"default_portrait_msg@2x" ofType:@"png"];
    _defaultPortrait = [UIImage imageWithContentsOfFile:imgPath];
    
    _imgvCall = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _imgvCall.image = [UIImage imageNamed:@"v2-btn_phone"];
    
    CBIMDataSource* imDS = [CBIMDataSource sharedInstance];
    self.teacherList = [NSMutableArray array];
    self.relationshipGroupList = [NSMutableArray array];
    
    NSArray* components = [self.targetId componentsSeparatedByString:@"_"];
    if (components.count == 2) {
        _schoolId = [components[0] integerValue];
        _classId = [components[1] integerValue];
    }
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    CBHttpClient* http = [CBHttpClient sharedInstance];
    
    if (self.segMemberType.selectedSegmentIndex == 0) {
        if (self.teacherList.count > 0) {
            [self reloadUI];
        }
        else {
            if (_schoolId >0 && _classId>0) {
                [gApp waitingAlert:@"正在获取数据"];
                [http reqGetTeachersOfKindergarten:_schoolId
                                       withClassId:_classId
                                           success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                               [gApp hideAlert];
                                               for (NSDictionary* json in dataJson) {
                                                   CBTeacherInfo* newObj = [CBTeacherInfo instanceWithDictionary:json];
                                                   if (newObj) {
                                                       [self.teacherList addObject:newObj];
                                                   }
                                               }
                                               [self reloadUI];
                                               
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               [gApp hideAlert];
                                           }];
            }
            else {
                CSLog(@"ERR-1:%s", __FUNCTION__);
            }
        }
    }
    else if (self.segMemberType.selectedSegmentIndex == 1) {
        if (self.relationshipGroupList.count > 0) {
            [self reloadUI];
        }
        else {
            if (_schoolId >0 && _classId>0) {
                [gApp waitingAlert:@"正在获取数据"];
                [http reqGetRelationshipsOfKindergarten:_schoolId
                                            withClassId:_classId
                                                success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                                    [gApp hideAlert];
                                                    for (NSDictionary* json in dataJson) {
                                                        CBRelationshipInfo* newObj = [CBRelationshipInfo instanceWithDictionary:json];
                                                        if (newObj) {
                                                            [self.relationshipGroupList addObject:newObj];
                                                        }
                                                    }
                                                    [self reloadUI];
                                                    
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [gApp hideAlert];
                                                }];
            }
            else {
                CSLog(@"ERR-1:%s", __FUNCTION__);
            }
        }
    }
}

- (void)reloadUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    if (self.segMemberType.selectedSegmentIndex == 0) {
        numberOfSections = 1;
    }
    else if (self.segMemberType.selectedSegmentIndex == 1) {
        numberOfSections = 1;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (self.segMemberType.selectedSegmentIndex == 0) {
        numberOfRows = self.teacherList.count;
    }
    else if (self.segMemberType.selectedSegmentIndex == 1) {
        numberOfRows = self.relationshipGroupList.count;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBIMGroupTeacherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CBIMGroupTeacherTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (self.segMemberType.selectedSegmentIndex == 0) {
        CBTeacherInfo* cellData = [self.teacherList objectAtIndex:indexPath.row];
        [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:cellData.portrait]
                        placeholderImage:_defaultPortrait];
        cell.labTitle.text = [NSString stringWithFormat:@"%@老师", cellData.name];
    }
    else if (self.segMemberType.selectedSegmentIndex == 1) {
        CBRelationshipInfo* cellData = [self.relationshipGroupList objectAtIndex:indexPath.row];
        [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:cellData.parent.portrait]
                        placeholderImage:_defaultPortrait];
        cell.labTitle.text = [NSString stringWithFormat:@"%@%@", [cellData.child displayNick], cellData.relationship];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CBIMGroupTeacherTableViewCell class]]) {
        CBIMGroupTeacherTableViewCell* ccell = (CBIMGroupTeacherTableViewCell*)cell;
        ccell.imgIcon.layer.cornerRadius = ccell.imgIcon.bounds.size.width/2;
        ccell.imgIcon.clipsToBounds = YES;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.segMemberType.selectedSegmentIndex == 0) {
        CBTeacherInfo* cellData = [self.teacherList objectAtIndex:indexPath.row];
        NSString* userId = [NSString stringWithFormat:@"t_%@_Some(%@)_%@", @(_schoolId), cellData.uid, cellData.phone];
        
        [[CBIMDataSource sharedInstance] getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            CBIMChatViewController *conversationVC = [[CBIMChatViewController alloc]init];
            conversationVC.conversationType = ConversationType_PRIVATE;
            conversationVC.targetId = userId;
            conversationVC.userName = userInfo.name;
            conversationVC.title = userInfo.name;
            
            [self.navigationController pushViewController:conversationVC animated:YES];
        }];
    }
    else if (self.segMemberType.selectedSegmentIndex == 1) {
        CBRelationshipInfo* cellData = [self.relationshipGroupList objectAtIndex:indexPath.row];
        NSString* userId = [NSString stringWithFormat:@"p_%@_Some(%@)_%@", @(_schoolId), cellData.parent._id, cellData.parent.phone];
        
        [[CBIMDataSource sharedInstance] getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            CBIMChatViewController *conversationVC = [[CBIMChatViewController alloc]init];
            conversationVC.conversationType = ConversationType_PRIVATE;
            conversationVC.targetId = userId;
            conversationVC.userName = userInfo.name;
            conversationVC.title = userInfo.name;
            
            [self.navigationController pushViewController:conversationVC animated:YES];
        }];
    }
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)onSegMemberTypeValueChanged:(id)sender {
    [self reloadData];
}

@end

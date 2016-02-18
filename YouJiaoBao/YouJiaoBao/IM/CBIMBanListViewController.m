//
//  CBIMBanListViewController.m
//  YouJiaoBao
//
//  Created by WangXin on 1/25/16.
//  Copyright © 2016 Codingsoft. All rights reserved.
//

#import "CBIMBanListViewController.h"
#import "CBIMDataSource.h"
#import "CBTeacherInfo.h"
#import "CBRelationshipInfo.h"
#import "CSAppDelegate.h"
#import "CSHttpClient.h"
#import "CBIMBanTableViewCell.h"
#import "CSEngine.h"
#import "CBIMBanTableViewCell.h"
#import "CBIMBanInfo.h"

@interface CBIMBanListViewController () {
    NSInteger _schoolId;
    NSInteger _classId;
}

@property (nonatomic, strong) NSMutableArray* relationshipGroupList;
@property (nonatomic, strong) NSMutableArray* bandInfoList;
@end

@implementation CBIMBanListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.01)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.01)];
    
    CBIMDataSource* imDS = [CBIMDataSource sharedInstance];
    self.relationshipGroupList = [NSMutableArray array];
    self.bandInfoList = [NSMutableArray array];
    
    NSArray* components = [self.targetId componentsSeparatedByString:@"_"];
    if (components.count == 2) {
        _schoolId = [components[0] integerValue];
        _classId = [components[1] integerValue];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBanSwitchChanged:) name:@"noti.im.ban.changed" object:nil];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    [self reloadParentList];
    [self reloadBandList];
}

- (void)reloadParentList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    if (self.relationshipGroupList.count > 0) {
        [self reloadUI];
    }
    else if (_schoolId >0 && _classId>0) {
        [gApp waitingAlert:@"正在获取数据"];
        [http reqGetRelationshipsOfKindergarten:_schoolId
                                    withClassId:_classId
                                        success:^(AFHTTPRequestOperation *operation, id dataJson) {
                                            [gApp hideAlert];
                                            
                                            NSMutableDictionary* groupedDict = [NSMutableDictionary dictionary];
                                            for (NSDictionary* json in dataJson) {
                                                CBRelationshipInfo* newObj = [CBRelationshipInfo instanceWithDictionary:json];
                                                NSMutableArray* childRelationships = [groupedDict objectForKey:newObj.child.child_id];
                                                if (childRelationships == nil) {
                                                    childRelationships = [NSMutableArray array];
                                                    [groupedDict setObject:childRelationships forKey:newObj.child.child_id];
                                                }
                                                [childRelationships addObject:newObj];
                                            }
                                            
                                            [self.relationshipGroupList removeAllObjects];
                                            
                                            for (NSNumber* dictKey in groupedDict) {
                                                NSMutableArray* childRelationships = [groupedDict objectForKey:dictKey];
                                                if (childRelationships) {
                                                    [self.relationshipGroupList addObject:childRelationships];
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

- (void)reloadBandList {
    if (_schoolId >0 && _classId>0) {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        [http reqGetBandListOfKindergarten:_schoolId
                               withClassId:_classId
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [self.bandInfoList removeAllObjects];
                                       for (NSDictionary* json in responseObject) {
                                           CBIMBanInfo* banInfo = [CBIMBanInfo instanceWithDictionary:json];
                                           [self.bandInfoList addObject:banInfo];
                                       }
                                       [self reloadUI];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [gApp hideAlert];
                                   }];
    }
}

- (void)reloadUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    numberOfSections = self.relationshipGroupList.count;
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    NSMutableArray* arr = [self.relationshipGroupList objectAtIndex:section];
    numberOfRows = arr.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBIMBanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CBIMBanTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    CSEngine* engine = [CSEngine sharedInstance];
    NSMutableArray* arr = [self.relationshipGroupList objectAtIndex:indexPath.section];
    CBRelationshipInfo* cellData = [arr objectAtIndex:indexPath.row];
    cell.labName.text = [NSString stringWithFormat:@"%@%@", [cellData.child displayNick], cellData.relationship];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // imUserId=p_2041_Some(20001)_13018217525
    NSString* imUserId = [NSString stringWithFormat:@"p_%@_Some(%@)_%@", cellData.parent.school_id, cellData.parent._id, cellData.parent.phone];
    NSArray* matched = [self.bandInfoList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"_id == %@", imUserId]];
    
    cell.switchBan.on = (matched.count>0);
    
    cell.schoolId = _schoolId;
    cell.classId = _classId;
    cell.imUserId = imUserId;
    
    CSLog(@"imUserId=%@", imUserId);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell* cellHeader = nil;
    cellHeader = [tableView dequeueReusableCellWithIdentifier:@"CBGroupMemberCellHeader"];
    UILabel* labName = [cellHeader.contentView viewWithTag:100];
    
    NSMutableArray* arr = [self.relationshipGroupList objectAtIndex:section];
    CBRelationshipInfo* cellData = arr.firstObject;
    labName.text = [cellData.child displayNick];
    
    return cellHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 28;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)onBanSwitchChanged:(NSNotification*)noti {
    CBIMBanTableViewCell* cell = noti.object;
    if (cell) {
        CSHttpClient* http = [CSHttpClient sharedInstance];
        if (cell.switchBan.on) {
            [gApp waitingAlert:@"禁言用户"];
            [http reqAddBandUser:cell.imUserId
                  inKindergarten:cell.schoolId
                     withClassId:cell.classId
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             [gApp alert:@"禁言用户成功"];
                             [self reloadBandList];
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             [gApp alert:@"禁言用户失败"];
                             CSLog(@"reqAddBandUser err:%@", error);
                             [self reloadBandList];
                         }];
        }
        else {
            [gApp waitingAlert:@"解除禁言"];
            [http reqDeleteBandUser:cell.imUserId
                     inKindergarten:cell.schoolId
                        withClassId:cell.classId
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [gApp alert:@"解除禁言成功"];
                                [self reloadBandList];
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [gApp alert:@"解除禁言失败"];
                                CSLog(@"reqDeleteBandUser err:%@", error);
                                [self reloadBandList];
                            }];
        }
    }
}

@end
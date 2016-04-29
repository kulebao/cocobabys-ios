//
//  CSStudentListMainTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSStudentListMainTableViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CSChildListItemTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CSChildProfileViewController.h"
#import "ModelClassData.h"
#import "NSDate+CSKit.h"
#import "CSAppDelegate.h"

@interface CSStudentListMainTableViewController () <NSFetchedResultsControllerDelegate> {
    NSMutableArray* _classChildren;
    NSURLSessionDataTask* _opReloadDailylogList;
}

@end

@implementation CSStudentListMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(onBtnRefreshClicked:)];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];

    [self updateTableView];
    //[self doRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBtnRefreshClicked:(id)sender {
    [self doRefresh];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _classChildren.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    if (section < _classChildren.count) {
        ModelClassData* classData = [_classChildren objectAtIndex:section];
        if(classData.expand) {
            NSArray* childrenList = classData.childrenList;
            numberOfRows = childrenList.count;
        }
        else {
            numberOfRows = 0;
        }
    }
    
    return numberOfRows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ModelClassData* classData = [_classChildren objectAtIndex:section];
    [classData.classHeaderView reloadData];
    return classData.classHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSChildListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSChildListItemTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    ModelClassData* classData = [_classChildren objectAtIndex:indexPath.section];
    NSArray* childrenList = classData.childrenList;
    CBChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];
    
    [cell.imgPortrait sd_setImageWithURL:[NSURL URLWithString:childInfo.portrait]
                        placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    cell.imgPortrait.layer.cornerRadius = 29;
    cell.imgPortrait.clipsToBounds = YES;
    
    cell.labName.text = childInfo.name;
    
    CBDailylogInfo* dailyLog = [session getDailylogInfoByChildId:childInfo.child_id];
    if ([dailyLog isToday]) {
        NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:dailyLog.timestamp.longLongValue/1000.0] isoDateTimeString];
        NSString* body = @"";
        if (dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckIn) {
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡入园。", dailyLog.parent_name, timestampString];
        }
        else if (dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckOut){
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡离园。", dailyLog.parent_name, timestampString];
        }
        else if (dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckInCarMorning
                 || dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckInCarAfternoon){
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡坐上校车。", dailyLog.parent_name, timestampString];
        }
        else if (dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckOutCarMorning
                 || dailyLog.notice_type.integerValue == kKuleNoticeTypeCheckOutCarAfternoon){
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡离开校车。", dailyLog.parent_name, timestampString];
        }
        else {
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡(type:%@)。", dailyLog.parent_name, timestampString, dailyLog.notice_type];
        }
        
        cell.labNotification.text = body;
    }
    else {
        cell.labNotification.text = @"未刷卡";
    }
    
    cell.labMessage.text = @"";
    cell.imgNewMsg.hidden = YES;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ModelClassData* classData = [_classChildren objectAtIndex:indexPath.section];
    NSArray* childrenList = classData.childrenList;
    CBChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];
    
    CSLog(@"Select Child:%@", childInfo);
    
    [self performSegueWithIdentifier:@"segue.babylist.childprofile" sender:childInfo];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"segue.babylist.childprofile"]) {
        CSChildProfileViewController* ctrl = [segue destinationViewController];
        ctrl.childInfo = sender;
    }
}

- (void)doRefresh {
    [self reloadClassList];
}

- (void)reloadClassList {
    CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    [gApp waitingAlert:@"获取信息" withTitle:@"请稍候"];
    [session reloadClassList:^(NSError *error) {
        [engine onLoadClassInfoList:session.classInfoList];
        [self reloadChildList];
    }];
}

- (void)reloadChildList {
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    [gApp waitingAlert:@"获取信息" withTitle:@"请稍候"];
    [session reloadRelationships:^(NSError *error) {
        [self reloadDailylogList];
    }];
}

- (void)reloadDailylogList{
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    NSArray* classInfoList = session.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (CBClassInfo* classInfo in classInfoList) {
        [classIdList addObject:[@(classInfo.class_id) stringValue]];
    }
    
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    id success = ^(NSURLSessionDataTask *task, id jsonObjectList) {
        [session updateDailylogsByJsonObject:jsonObjectList];
        [self updateTableView];
        [gApp hideAlert];
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        _opReloadDailylogList = nil;
        [self updateTableView];
        [gApp hideAlert];
    };
    
    if (_opReloadDailylogList) {
        [_opReloadDailylogList cancel];
    }
    [gApp waitingAlert:@"获取信息" withTitle:@"请稍候"];
    _opReloadDailylogList = [http opGetDailyLogListOfKindergarten:session.loginInfo.school_id.integerValue
                                                    withClassList:classIdList
                                                          success:success
                                                          failure:failure];
}

#pragma mark - Private
- (void)updateTableView {
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    _classChildren = [NSMutableArray array];
    NSArray* childrenList = session.childInfoList;
    
    for (CBClassInfo* classInfo in session.classInfoList) {
        NSArray* classChildren = [childrenList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class_id == %ld", classInfo.class_id]];
        
        ModelClassData* classData = [ModelClassData new];
        classData.classInfo = classInfo;
        classData.childrenList = classChildren;
        classData.expand = NO;
        classData.classHeaderView = [CSClassHeaderView defaultClassHeaderView];
        classData.classHeaderView.modelData = classData;
        classData.classHeaderView.delegate = self;
        
        [_classChildren addObject:classData];
    }
    
    [self.tableView reloadData];
}

#pragma mark - CSClassHeaderViewDelegate
- (void)classHeaderViewExpandChanged:(CSClassHeaderView*)view {
    [self.tableView reloadData];
}

@end
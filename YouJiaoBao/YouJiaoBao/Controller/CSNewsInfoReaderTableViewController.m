//
//  CSNewsInfoReaderTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 10/10/15.
//  Copyright © 2015-2016 Cocobabys. All rights reserved.
//

#import "CSNewsInfoReaderTableViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CSNewsReaderTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CSChildProfileViewController.h"
#import "ModelClassData.h"
#import "NSDate+CSKit.h"
#import "CSAppDelegate.h"

@interface CSNewsInfoReaderTableViewController ()<NSFetchedResultsControllerDelegate> {
    NSMutableArray* _classChildren;
    NSMutableSet* _childrenReaders;

    NSURLSessionDataTask* _opReloadClassList;
    NSURLSessionDataTask* _opReloadChildList;
}

@end

@implementation CSNewsInfoReaderTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    [self reloadData];
    [self doRefresh];
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
    CSNewsReaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSNewsReaderTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    ModelClassData* classData = [_classChildren objectAtIndex:indexPath.section];
    NSArray* childrenList = classData.childrenList;
    CBChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];
    
    [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:childInfo.portrait]
                        placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    cell.imgIcon.layer.cornerRadius = 29;
    cell.viewMask.layer.cornerRadius = cell.imgIcon.layer.cornerRadius;
    cell.imgIcon.clipsToBounds = YES;
    
    cell.labName.text = childInfo.name;
    
    if ([_childrenReaders containsObject:childInfo]) {
        cell.labStatus.text = @"已回执";
        cell.labStatus.textColor = UIColorRGB(10, 163, 221); //0x0aa3dd
        cell.viewMask.hidden = YES;
    }
    else {
        cell.labStatus.text = @"未回执";
        cell.labStatus.textColor = [UIColor grayColor];
        cell.viewMask.hidden = NO;
    }
    
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

- (void)doRefresh2 {
    [self reloadChildList];
}

- (void)reloadClassList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        [session updateClassInfosByJsonObject:responseObject];
        [engine onLoadClassInfoList:session.classInfoList];
        
        [self doRefresh2];
        _opReloadClassList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse* response = (NSHTTPURLResponse*) task.response;
        if (response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiUnauthorized
                                                                object:error
                                                              userInfo:nil];
        }
        else {
            [self doRefresh2];
        }
        _opReloadClassList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    if (_opReloadClassList) {
        [_opReloadClassList cancel];
    }
    
    [gApp waitingAlert:@"获取信息" withTitle:@"请稍候"];
    _opReloadClassList = [http opGetClassListOfKindergarten:session.loginInfo.school_id.integerValue
                                             withEmployeeId:session.loginInfo.phone
                                                    success:success
                                                    failure:failure];
}

- (void)reloadChildList {
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    NSArray* classInfoList = session.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (CBClassInfo* classInfo in classInfoList) {
        [classIdList addObject:[@(classInfo.class_id) stringValue]];
    }
    
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    id success = ^(NSURLSessionDataTask *task, id jsonObjectList) {
        [session updateChildInfosByJsonObject:jsonObjectList];
        _opReloadChildList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        _opReloadChildList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    if (_opReloadChildList) {
        [_opReloadChildList cancel];
    }
    [gApp waitingAlert:@"获取信息" withTitle:@"请稍候"];
    _opReloadChildList = [http opGetChildListOfKindergarten:session.loginInfo.school_id.integerValue
                                              withClassList:classIdList
                                                    success:success
                                                    failure:failure];
}

- (void)hideWaitingAlertIfNeeded {
    if (_opReloadClassList == nil
        && _opReloadChildList == nil) {
        [gApp hideAlert];
    }
}

#pragma mark - Private
- (void)reloadData {
    _childrenReaders = [NSMutableSet set];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    for (CBRelationshipInfo* relationship in session.relationshipInfoList) {
        NSArray* arr = [self.readerList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parent_id == %@", relationship.parent.parent_id]];
        if (arr.count > 0) {
            if (relationship.child) {
                [_childrenReaders addObject:relationship.child];
            }
        }
    }
    
    _classChildren = [NSMutableArray array];
    NSArray* childrenList = session.childInfoList;
    
    for (CBClassInfo* classInfo in session.classInfoList) {
        if (self.newsInfo.class_id.integerValue > 0 && self.newsInfo.class_id.integerValue != classInfo.class_id) {
            continue;
        }
        
        NSArray* classChildren = [childrenList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class_id == %ld", classInfo.class_id]];
        
        classChildren = [classChildren sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(CBClassInfo* obj1, CBClassInfo* obj2) {
            NSComparisonResult result = NSOrderedSame;
            
            NSNumber* v1 = [_childrenReaders containsObject:obj1] ? @(1) : @(-1);
            NSNumber* v2 = [_childrenReaders containsObject:obj2] ? @(1) : @(-1);
            
            result = [v1 compare:v2];

            return result;
        }];
        
        ModelReaderData* classData = [ModelReaderData new];
        classData.classInfo = classInfo;
        classData.childrenList = classChildren;
        classData.childrenReaders = _childrenReaders;
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

//
//  CSNewsInfoReaderTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 10/10/15.
//  Copyright © 2015 Codingsoft. All rights reserved.
//

#import "CSNewsInfoReaderTableViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "EntityClassInfoHelper.h"
#import "EntityChildInfoHelper.h"
#import "CSNewsReaderTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CSChildProfileViewController.h"
#import "ModelClassData.h"
#import "NSDate+CSKit.h"
#import "CSAppDelegate.h"
#import "EntityRelationshipInfoHelper.h"

@interface CSNewsInfoReaderTableViewController ()<NSFetchedResultsControllerDelegate> {
    NSMutableArray* _classChildren;
    NSMutableSet* _childrenReaders;
    NSFetchedResultsController* _frClasses;
    NSFetchedResultsController* _frChildren;
    NSFetchedResultsController* _frRelationship;
    
    AFHTTPRequestOperation* _opReloadClassList;
    AFHTTPRequestOperation* _opReloadChildList;
    AFHTTPRequestOperation* _opReloadDailylogList;
    AFHTTPRequestOperation* _opReloadSessionList;
}

@end

@implementation CSNewsInfoReaderTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    [self customizeBackBarItem];
    //[self customizeOkBarItemWithTarget:self action:@selector(onBtnRefreshClicked:) text:@"刷新"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    CSEngine* engine = [CSEngine sharedInstance];
    
    _frClasses = [EntityClassInfoHelper frClassesWithEmployee:engine.loginInfo.uid ofKindergarten:engine.loginInfo.schoolId.integerValue];
    _frClasses.delegate = self;
    
    NSError* error = nil;
    BOOL ok = [_frClasses performFetch:&error];
    if (!ok) {
        CSLog(@"1 error: %@", error);
    }
    
    _frChildren = [EntityChildInfoHelper frChildrenWithKindergarten:engine.loginInfo.schoolId.integerValue];
    _frChildren.delegate = self;
    ok = [_frChildren performFetch:&error];
    if (!ok) {
        CSLog(@"2 error: %@", error);
    }
    
    _frRelationship = [EntityRelationshipInfoHelper frRelationshipOfKindergarten:engine.loginInfo.schoolId.integerValue];
    _frRelationship.delegate = self;
    ok = [_frRelationship performFetch:&error];
    if (!ok) {
        CSLog(@"3 error: %@", error);
    }
    
    [self updateTableView];
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
    EntityChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];
    
    [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:childInfo.portrait]
                        placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    cell.imgIcon.layer.cornerRadius = 29;
    cell.viewMask.layer.cornerRadius = cell.imgIcon.layer.cornerRadius;
    cell.imgIcon.clipsToBounds = YES;
    
    cell.labName.text = childInfo.name;
    
    if ([_childrenReaders containsObject:childInfo]) {
        cell.labStatus.text = @"已回执";
        cell.labStatus.textColor = UIColorRGB(14, 188, 255);
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
    EntityChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];
    
    CSLog(@"child:%@", childInfo);
    
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
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* classInfoList = [EntityClassInfoHelper updateEntities:responseObject
                                                           forEmployee:engine.loginInfo.uid
                                                        ofKindergarten:engine.loginInfo.schoolId.integerValue];
        [engine onLoadClassInfoList:classInfoList];
        
        [self doRefresh2];
        _opReloadClassList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {
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
    _opReloadClassList = [http opGetClassListOfKindergarten:engine.loginInfo.schoolId.integerValue
                                             withEmployeeId:engine.loginInfo.phone
                                                    success:success
                                                    failure:failure];
}

- (void)reloadChildList {
    CSEngine* engine = [CSEngine sharedInstance];
    NSArray* classInfoList = engine.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (EntityClassInfo* classInfo in classInfoList) {
        [classIdList addObject:classInfo.classId.stringValue];
    }
    
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id jsonObjectList) {
        [EntityChildInfoHelper updateEntities:jsonObjectList];
        _opReloadChildList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        _opReloadChildList = nil;
        [self hideWaitingAlertIfNeeded];
    };
    
    if (_opReloadChildList) {
        [_opReloadChildList cancel];
    }
    [gApp waitingAlert:@"获取信息" withTitle:@"请稍候"];
    _opReloadChildList = [http opGetChildListOfKindergarten:engine.loginInfo.schoolId.integerValue
                                              withClassList:classIdList
                                                    success:success
                                                    failure:failure];
}

- (void)hideWaitingAlertIfNeeded {
    if (_opReloadClassList == nil
        && _opReloadChildList == nil
        && _opReloadDailylogList == nil
        && _opReloadSessionList == nil) {
        [gApp hideAlert];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([controller isEqual:_frClasses]) {
        [self updateTableView];
    }
    else if ([controller isEqual:_frChildren]) {
        [self updateTableView];
    }
}

#pragma mark - Private
- (void)updateTableView {
    _childrenReaders = [NSMutableSet set];
    for (EntityRelationshipInfo* relationship in _frRelationship.fetchedObjects) {
        if ([self.readerList containsObject:relationship.parentInfo]) {
            if (relationship.childInfo) {
                [_childrenReaders addObject:relationship.childInfo];
            }
        }
    }
    
    _classChildren = [NSMutableArray array];
    NSArray* childrenList = _frChildren.fetchedObjects;
    
    for (EntityClassInfo* classInfo in _frClasses.fetchedObjects) {
        if (self.newsInfo.classId.integerValue > 0 && self.newsInfo.classId.integerValue != classInfo.classId.integerValue) {
            continue;
        }
        
        NSArray* classChildren = [childrenList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"classId == %@", classInfo.classId]];
        
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

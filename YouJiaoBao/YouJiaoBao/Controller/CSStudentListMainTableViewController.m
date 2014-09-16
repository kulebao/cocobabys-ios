//
//  CSStudentListMainTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSStudentListMainTableViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "EntityClassInfoHelper.h"
#import "EntityChildInfoHelper.h"
#import "EntityDailylogHelper.h"
#import "CSChildListItemTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CSChildProfileViewController.h"
#import "ModelClassData.h"
#import "NSDate+CSKit.h"

@interface CSStudentListMainTableViewController () <NSFetchedResultsControllerDelegate> {
    NSMutableArray* _classChildren;
    NSFetchedResultsController* _frClasses;
    NSFetchedResultsController* _frChildren;
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
    
    [self customizeBackBarItem];
    [self customizeOkBarItemWithTarget:self action:@selector(onBtnRefreshClicked:) text:@"刷新"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    CSEngine* engine = [CSEngine sharedInstance];

    _frClasses = [EntityClassInfoHelper frClassesWithEmployee:engine.loginInfo.uid ofKindergarten:engine.loginInfo.schoolId.integerValue];
    _frClasses.delegate = self;
    
    NSError* error = nil;
    BOOL ok = [_frClasses performFetch:&error];
    if (!ok) {
        CSLog(@"error: %@", error);
    }
    
    _frChildren = [EntityChildInfoHelper frChildrenWithKindergarten:engine.loginInfo.schoolId.integerValue];
    _frChildren.delegate = self;
    ok = [_frChildren performFetch:&error];
    if (!ok) {
        CSLog(@"error: %@", error);
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
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSChildListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSChildListItemTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    ModelClassData* classData = [_classChildren objectAtIndex:indexPath.section];
    NSArray* childrenList = classData.childrenList;
    EntityChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];
    
    [cell.imgPortrait sd_setImageWithURL:[NSURL URLWithString:childInfo.portrait]
                   placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    
    cell.labName.text = childInfo.name;
    
    EntityDailylog* dailyLog = childInfo.dailylog;
    if (dailyLog && [EntityDailylogHelper isDailylogOfToday:dailyLog]) {
        NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:dailyLog.timestamp.longLongValue/1000.0] isoDateTimeString];
        NSString* body = @"";
        if (dailyLog.noticeType.integerValue == kKuleNoticeTypeCheckIn) {
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡入园。", dailyLog.parentName, timestampString];
        }
        else if (dailyLog.noticeType.integerValue == kKuleNoticeTypeCheckOut){
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡离园。", dailyLog.parentName, timestampString];
        }
        else {
            body = [NSString stringWithFormat:@"由 %@ 于 %@ 刷卡(%@)。", dailyLog.parentName, timestampString, dailyLog.noticeType];
        }
        
        cell.labNotification.text = body;
    }
    else {
        cell.labNotification.text = @"未刷卡";
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
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
    [self reloadChildList];
    [self reloadDailylogList];
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
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
    };
    
    [http opGetChildListOfKindergarten:engine.loginInfo.schoolId.integerValue
                         withClassList:classIdList
                               success:success
                               failure:failure];
}

- (void)reloadDailylogList{
    CSEngine* engine = [CSEngine sharedInstance];
    NSArray* classInfoList = engine.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (EntityClassInfo* classInfo in classInfoList) {
        [classIdList addObject:classInfo.classId.stringValue];
    }
    
    CSHttpClient* http = [CSHttpClient sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id jsonObjectList) {
        [EntityDailylogHelper updateEntities:jsonObjectList];
        [self.tableView reloadData];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
    };
    
    [http opGetDailyLogListOfKindergarten:engine.loginInfo.schoolId.integerValue
                            withClassList:classIdList
                                  success:success
                                  failure:failure];
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
    _classChildren = [NSMutableArray array];
    NSArray* childrenList = _frChildren.fetchedObjects;
    
    for (EntityClassInfo* classInfo in _frClasses.fetchedObjects) {
        NSArray* classChildren = [childrenList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"classId == %@", classInfo.classId]];
        
        ModelClassData* classData = [ModelClassData new];
        classData.classInfo = classInfo;
        classData.childrenList = classChildren;
        classData.expand = YES;
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

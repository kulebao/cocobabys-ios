//
//  CSStudentListPickUpTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-11-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSStudentListPickUpTableViewController.h"
#import "CSAppDelegate.h"
#import "CSEngine.h"
#import "CSHttpClient.h"
#import "CSStudentPickerHeaderView.h"
#import "EntityClassInfoHelper.h"
#import "EntityChildInfoHelper.h"
#import "ModelClassData.h"
#import "CSChildListItemTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+CSKit.h"

@interface CSStudentListPickUpTableViewController () <NSFetchedResultsControllerDelegate> {
    NSMutableArray* _classChildren;
    NSFetchedResultsController* _frClasses;
    NSFetchedResultsController* _frChildren;
    
    NSMutableSet* _selectedChildren;
}

@end

@implementation CSStudentListPickUpTableViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self customizeBackBarItem];
    [self customizeOkBarItemWithTarget:self action:@selector(onBtnSendClicked:) text:@"发布"];
    self.navigationItem.title = @"请选择";
    
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
    
    _selectedChildren = [NSMutableSet set];
    
    [self updateTableView];
    [self doRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBtnSendClicked:(id)sender {
    if (_selectedChildren.count == 0) {
        [gApp alert:@"必须选择至少一个小孩"];
    }
    else if ([_delegate respondsToSelector:@selector(studentListPickUpTableViewController:didPickUp:)]) {
        [_delegate studentListPickUpTableViewController:self didPickUp:[_selectedChildren allObjects]];
    }
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
    [classData.studentPickerHeaderView reloadData];
    return classData.studentPickerHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
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
    
    if ([_selectedChildren containsObject:childInfo]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ModelClassData* classData = [_classChildren objectAtIndex:indexPath.section];
    NSArray* childrenList = classData.childrenList;
    EntityChildInfo* childInfo = [childrenList objectAtIndex:indexPath.row];

    if ([_selectedChildren containsObject:childInfo]) {
        [_selectedChildren removeObject:childInfo];
    }
    else {
        [_selectedChildren addObject:childInfo];
    }
    
    [classData.studentPickerHeaderView reloadData];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationNone];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)doRefresh {
    [self reloadChildList];
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
        classData.studentPickerHeaderView = [CSStudentPickerHeaderView defaultClassHeaderView];
        classData.studentPickerHeaderView.modelData = classData;
        classData.studentPickerHeaderView.delegate = self;
        classData.studentPickerHeaderView.sharedSelectedChildren = _selectedChildren;
        
        [_classChildren addObject:classData];
    }
    
    [self.tableView reloadData];
}

#pragma mark - CSStudentPickerHeaderViewDelegate
- (void)studentPickerHeaderViewExpandChanged:(CSStudentPickerHeaderView*)view {
    NSInteger section = [_classChildren indexOfObject:view.modelData];
    if (section >= 0) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)studentPickerHeaderViewSelectionhanged:(CSStudentPickerHeaderView*)view {
    NSInteger section = [_classChildren indexOfObject:view.modelData];
    if (section >= 0) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end

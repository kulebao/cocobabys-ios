//
//  CSKuleAssignmentViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleAssignmentViewController.h"
#import "CSKuleNoticeCell.h"
#import "PullTableView.h"
#import "CSAppDelegate.h"
#import "CSKuleNewsDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface CSKuleAssignmentViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
@property (weak, nonatomic) IBOutlet PullTableView *tableview;
@property (nonatomic, strong) NSMutableArray* assignmentInfoList;

@end

@implementation CSKuleAssignmentViewController
@synthesize assignmentInfoList = _assignmentInfoList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.pullDelegate = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    _assignmentInfoList = [NSMutableArray array];
    
    [gApp waitingAlert:@"正在获取数据"];
    [self reloadAssignmentList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _assignmentInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleNoticeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNoticeCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleNoticeCell" owner:nil options:nil];
        cell = [nibs firstObject];
        cell.imgIcon.image = [UIImage imageNamed:@"icon-assignment.png"];
    }
    
    CSKuleAssignmentInfo* assignmentInfo = [self.assignmentInfoList objectAtIndex:indexPath.row];
    cell.labTitle.text = assignmentInfo.title;
    cell.labContent.text = assignmentInfo.content;
    
    NSString* publiser = nil;
    if (assignmentInfo.classId > 0 && assignmentInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser =  [NSString stringWithFormat:@"%@ %@", gApp.engine.loginInfo.schoolName, gApp.engine.currentRelationship.child.className];
    }
    else {
        publiser = gApp.engine.loginInfo.schoolName;
    }
    
    if (assignmentInfo.iconUrl.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:assignmentInfo.iconUrl];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/0/w/50/h/50"];
        
        [cell.imgAttachment setImageWithURL:qiniuImgUrl
                           placeholderImage:[UIImage imageNamed:@"chating-picture.png"]];
    }
    else {
        [cell.imgAttachment cancelImageRequestOperation];
        cell.imgAttachment.image = nil;
    }
    cell.imgAttachment.clipsToBounds = YES;
    cell.imgAttachment.layer.cornerRadius = 4;
    
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:assignmentInfo.timestamp];
    
    cell.labDate.text = [NSString stringWithFormat:@"%@ 来自:%@", [timestamp isoDateTimeString], publiser];
    cell.labPublisher.text = nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0+5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleAssignmentInfo* assignmentInfo = [self.assignmentInfoList objectAtIndex:indexPath.row];
    [self performSelector:@selector(showAssignmentDetails:) withObject:assignmentInfo];
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [self performSelector:@selector(refreshTable)
               withObject:nil
               afterDelay:.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    [self performSelector:@selector(loadMoreDataToTable)
               withObject:nil
               afterDelay:.0f];
}

- (void) refreshTable
{
    [self reloadAssignmentList];
}

- (void) loadMoreDataToTable
{
    [self loadMoreAssignmentList];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.assignmentdetails"]) {
        CSKuleNewsDetailsViewController* destCtrl = segue.destinationViewController;
        destCtrl.navigationItem.title = @"作业内容";
        destCtrl.assignmentInfo = sender;
    }
}

#pragma mark - Private
- (void)showAssignmentDetails:(CSKuleAssignmentInfo*)assignmentInfo {
    [self performSegueWithIdentifier:@"segue.assignmentdetails" sender:assignmentInfo];
}

- (void)reloadAssignmentList {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSMutableArray* assignmentInfos = [NSMutableArray array];
        
        for (id assignmentInfoJson in dataJson) {
            CSKuleAssignmentInfo* assignmentInfo = [CSKuleInterpreter decodeAssignmentInfo:assignmentInfoJson];
            [assignmentInfos addObject:assignmentInfo];
        }
        
        self.assignmentInfoList = assignmentInfos;
        
        if (_assignmentInfoList.count > 0) {
            [gApp hideAlert];
        }
        else {
            [gApp alert:@"没有亲子作业信息"];
        }
        
        self.tableview.pullLastRefreshDate = [NSDate date];
        self.tableview.pullTableIsRefreshing = NO;
        
        [self.tableview reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        self.tableview.pullTableIsRefreshing = NO;
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp.engine reqGetAssignmentsOfKindergarten:gApp.engine.loginInfo.schoolId
                                     from:-1
                                       to:-1
                                     most:-1
                                  success:sucessHandler
                                  failure:failureHandler];
}

- (void)loadMoreAssignmentList {
    CSKuleAssignmentInfo* lastAssignmentInfo = self.assignmentInfoList.lastObject;
    if (lastAssignmentInfo) {
        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            NSMutableArray* assignmentInfos = [NSMutableArray array];
            
            for (id assignmentInfoJson in dataJson) {
                CSKuleAssignmentInfo* assignmentInfo = [CSKuleInterpreter decodeAssignmentInfo:assignmentInfoJson];
                [assignmentInfos addObject:assignmentInfo];
            }
            
            if (assignmentInfos.count > 0) {
                [self.assignmentInfoList addObjectsFromArray:assignmentInfos];
                [gApp hideAlert];
            }
            else {
                [gApp alert:@"没有更多消息"];
            }
            
            self.tableview.pullTableIsLoadingMore = NO;
            [self.tableview reloadData];
        };
        
        FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
            CSLog(@"failure:%@", error);
            self.tableview.pullTableIsRefreshing = NO;
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp.engine reqGetAssignmentsOfKindergarten:gApp.engine.loginInfo.schoolId
                                         from:1
                                           to:lastAssignmentInfo.assignmentId
                                         most:25
                                      success:sucessHandler
                                      failure:failureHandler];
    }
    else {
        [self reloadAssignmentList];
    }
}

@end

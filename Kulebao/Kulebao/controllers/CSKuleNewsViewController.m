//
//  CSKuleNewsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsViewController.h"
#import "CSKuleNoticeCell.h"
#import "PullTableView.h"
#import "CSKuleNewsDetailsViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleNewsViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
@property (weak, nonatomic) IBOutlet PullTableView *tableview;
@property (nonatomic, strong) NSMutableArray* newsInfoList;

@end

@implementation CSKuleNewsViewController

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
    self.tableview.backgroundColor = [UIColor clearColor];
    
    self.tableview.pullDelegate = self;
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    _newsInfoList = [NSMutableArray array];

    [gApp waitingAlert:@"正在获取数据"];
    [self reloadNewsList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleNoticeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNoticeCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleNoticeCell" owner:nil options:nil];
        cell = [nibs firstObject];
        cell.imgIcon.image = [UIImage imageNamed:@"icon-news.png"];
    }
    
    CSKuleNewsInfo* newsInfo = [self.newsInfoList objectAtIndex:indexPath.row];
    cell.labTitle.text = newsInfo.title;
    cell.labContent.text = newsInfo.content;
    if (newsInfo.classId > 0 && newsInfo.classId == gApp.engine.currentRelationship.child.classId) {
        cell.labPublisher.text =  [NSString stringWithFormat:@"%@ %@", gApp.engine.loginInfo.schoolName, gApp.engine.currentRelationship.child.className];
    }
    else {
        cell.labPublisher.text = gApp.engine.loginInfo.schoolName;
    }
    
    if (newsInfo.image.length > 0) {
        [cell.imgAttachment setImageWithURL:[gApp.engine urlFromPath:newsInfo.image]];
    }
    else {
        [cell.imgAttachment cancelImageRequestOperation];
        cell.imgAttachment.image = nil;
    }
    
    NSDate* d = [NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp];
    
    cell.labDate.text = [d isoDateTimeString];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0+5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSKuleNewsInfo* newsInfo = [self.newsInfoList objectAtIndex:indexPath.row];
    [self performSelector:@selector(showNewsDetails:) withObject:newsInfo];
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
    /*
     
     Code to actually refresh goes here.
     
     */
    
    [self reloadNewsList];
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    [self loadMoreNewsList];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.newsdetails"]) {
        CSKuleNewsDetailsViewController* destCtrl = segue.destinationViewController;
        destCtrl.navigationItem.title = @"公告详情";
        destCtrl.newsInfo = sender;
    }
}

#pragma mark - Private
- (void)showNewsDetails:(CSKuleNewsInfo*)newsInfo {
    [self performSegueWithIdentifier:@"segue.newsdetails" sender:newsInfo];
}

- (void)reloadNewsList {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSMutableArray* newsInfos = [NSMutableArray array];
        
        for (id newsInfoJson in dataJson) {
            CSKuleNewsInfo* newsInfo = [CSKuleInterpreter decodeNewsInfo:newsInfoJson];
            [newsInfos addObject:newsInfo];
        }
        
        self.newsInfoList = newsInfos;
        [gApp hideAlert];
        
        self.tableview.pullLastRefreshDate = [NSDate date];
        self.tableview.pullTableIsRefreshing = NO;
        
        [self.tableview reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        self.tableview.pullTableIsRefreshing = NO;
        [gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    [gApp.engine reqGetNewsOfKindergarten:gApp.engine.loginInfo.schoolId
                              withClassId:currentChild.classId
                                     from:-1
                                       to:-1
                                     most:-1
                                  success:sucessHandler
                                  failure:failureHandler];
}

- (void)loadMoreNewsList {
    
    CSKuleNewsInfo* lastNewsInfo = self.newsInfoList.lastObject;
    if (lastNewsInfo) {
        SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
            NSMutableArray* newsInfos = [NSMutableArray array];
            
            for (id newsInfoJson in dataJson) {
                CSKuleNewsInfo* newsInfo = [CSKuleInterpreter decodeNewsInfo:newsInfoJson];
                [newsInfos addObject:newsInfo];
            }
            
            if (newsInfos.count > 0) {
                [self.newsInfoList addObjectsFromArray:newsInfos];
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
        
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        [gApp.engine reqGetNewsOfKindergarten:gApp.engine.loginInfo.schoolId
                                  withClassId:currentChild.classId
                                         from:1
                                           to:lastNewsInfo.newsId
                                         most:25
                                      success:sucessHandler
                                      failure:failureHandler];
    }
    else {
        [self reloadNewsList];
    }
}

@end

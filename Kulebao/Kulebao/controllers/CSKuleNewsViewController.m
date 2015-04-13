//
//  CSKuleNewsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsViewController.h"
//#import "CSKuleNoticeCell.h"
#import "PullTableView.h"
#import "CSKuleNewsDetailsViewController.h"
#import "CSAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "CSKuleNewsTableViewCell.h"

@interface CSKuleNewsViewController () <UITableViewDataSource,
                                        UITableViewDelegate,
                                        PullTableViewDelegate,
                                        CSKuleNewsInfoDelegate>

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
    
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"CSKuleNewsTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"CSKuleNewsTableViewCell"];
    
    _newsInfoList = [NSMutableArray array];
    [self reloadNewsList];
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
    return self.newsInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleNewsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNewsTableViewCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleNewsTableViewCell" owner:nil options:nil];
        cell = [nibs firstObject];
    }
    
    CSKuleNewsInfo* newsInfo = [self.newsInfoList objectAtIndex:indexPath.row];

    cell.labTitle.text = newsInfo.title;
    cell.labContent.text = newsInfo.content;
    
    NSString* publiser = nil;
    if (newsInfo.classId > 0 && newsInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser =  [NSString stringWithFormat:@"%@ %@", gApp.engine.loginInfo.schoolName, gApp.engine.currentRelationship.child.className];
    }
    else {
        publiser = gApp.engine.loginInfo.schoolName;
    }
    
    if (newsInfo.image.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:newsInfo.image];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/0/w/50/h/50"];
        [cell.imgAttachment sd_setImageWithURL:qiniuImgUrl
                              placeholderImage:[UIImage imageNamed:@"img-placeholder.png"]];
        cell.imgAttachment.hidden = NO;
        cell.iconWidth.constant = 48;
        cell.titleLeading.constant = 8;
    }
    else {
        [cell.imgAttachment cancelImageRequestOperation];
        cell.imgAttachment.image = nil;
        cell.imgAttachment.hidden = YES;
        cell.iconWidth.constant = 0;
        cell.titleLeading.constant = 0;
    }
    cell.imgAttachment.clipsToBounds = YES;
    cell.imgAttachment.layer.cornerRadius = 4;
    
    [cell setNeedsUpdateConstraints];
    
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp];
    
    cell.labPublisher.text = [NSString stringWithFormat:@"%@ 来自:%@", [timestamp timestampString], publiser];
    
    [cell loadNewsInfo:newsInfo];
    
    return cell;
}

/*
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
    
    NSString* publiser = nil;
    if (newsInfo.classId > 0 && newsInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser =  [NSString stringWithFormat:@"%@ %@", gApp.engine.loginInfo.schoolName, gApp.engine.currentRelationship.child.className];
    }
    else {
        publiser = gApp.engine.loginInfo.schoolName;
    }
    
    if (newsInfo.image.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:newsInfo.image];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/0/w/50/h/50"];
        [cell.imgAttachment sd_setImageWithURL:qiniuImgUrl
                           placeholderImage:[UIImage imageNamed:@"img-placeholder.png"]];
    }
    else {
        [cell.imgAttachment cancelImageRequestOperation];
        cell.imgAttachment.image = nil;
    }
    cell.imgAttachment.clipsToBounds = YES;
    cell.imgAttachment.layer.cornerRadius = 4;
    
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp];
    
    cell.labDate.text = [NSString stringWithFormat:@"%@ 来自:%@", [timestamp timestampString], publiser];
    cell.labPublisher.text = nil;
    
    return cell;
}
*/

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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
        destCtrl.navigationItem.title = @"通知内容";
        destCtrl.newsInfo = sender;
    }
}

#pragma mark - Private
- (void)showNewsDetails:(CSKuleNewsInfo*)newsInfo {
    [self performSegueWithIdentifier:@"segue.newsdetails" sender:newsInfo];
}

- (void)reloadNewsList {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* newsInfos = [NSMutableArray array];
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        NSTimeInterval timestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleNews forChild:currentChild.childId];
        for (id newsInfoJson in dataJson) {
            CSKuleNewsInfo* newsInfo = [CSKuleInterpreter decodeNewsInfo:newsInfoJson];
            [newsInfo reloadStatus];
            [newsInfos addObject:newsInfo];
            if (newsInfo.timestamp > timestamp) {
                timestamp = newsInfo.timestamp;
            }
        }
        [gApp.engine.preferences setTimestamp:timestamp ofModule:kKuleModuleNews forChild:currentChild.childId];
        
        self.newsInfoList = newsInfos;
        if (_newsInfoList.count > 0) {
            [gApp hideAlert];
        }
        else {
            [gApp alert:@"没有公告信息"];
        }
        
        self.tableview.pullLastRefreshDate = [NSDate date];
        self.tableview.pullTableIsRefreshing = NO;
        
        [self.tableview reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        self.tableview.pullTableIsRefreshing = NO;
        [gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        [gApp waitingAlert:@"正在获取数据"];
        [gApp.engine reqGetNewsOfKindergarten:gApp.engine.loginInfo.schoolId
                                  withClassId:currentChild.classId
                                         from:-1
                                           to:-1
                                         most:-1
                                      success:sucessHandler
                                      failure:failureHandler];
    }
    else {
        [gApp alert:@"没有宝宝信息。"];
    }
}

- (void)loadMoreNewsList {
    CSKuleNewsInfo* lastNewsInfo = self.newsInfoList.lastObject;
    if (lastNewsInfo) {
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSMutableArray* newsInfos = [NSMutableArray array];
            CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
            NSTimeInterval timestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleNews forChild:currentChild.childId];
            for (id newsInfoJson in dataJson) {
                CSKuleNewsInfo* newsInfo = [CSKuleInterpreter decodeNewsInfo:newsInfoJson];
                [newsInfos addObject:newsInfo];
                if (newsInfo.timestamp > timestamp) {
                    timestamp = newsInfo.timestamp;
                }
            }
            [gApp.engine.preferences setTimestamp:timestamp ofModule:kKuleModuleNews forChild:currentChild.childId];
            
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
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            self.tableview.pullTableIsLoadingMore = NO;
            [gApp alert:[error localizedDescription]];
        };
        
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        if (currentChild) {
            [gApp.engine reqGetNewsOfKindergarten:gApp.engine.loginInfo.schoolId
                                      withClassId:currentChild.classId
                                             from:1
                                               to:lastNewsInfo.newsId
                                             most:25
                                          success:sucessHandler
                                          failure:failureHandler];
        }
        else {
            [gApp alert:@"没有宝宝信息。"];
        }
    }
    else {
        [self reloadNewsList];
    }
}

@end

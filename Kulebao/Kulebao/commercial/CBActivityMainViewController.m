//
//  CBActivityMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityMainViewController.h"
#import "PullTableView.h"
#import "CSAppDelegate.h"
#import "CBActivityItemCell.h"
#import "CBActivityData.h"

@interface CBActivityMainViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>

@property (weak, nonatomic) IBOutlet PullTableView *tableview;
@property (nonatomic, strong) NSMutableArray* cellItemDataList;

@end

@implementation CBActivityMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    
    self.tableview.pullDelegate = self;
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0x99, 0x99, 0x99);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];

    _cellItemDataList = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)reloadData {
    if ([self isViewLoaded]) {
        self.tableview.pullTableIsRefreshing = YES;
        [self refreshTable];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellItemDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBActivityItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CBActivityItemCell"];
    CBActivityData* itemData = [self.cellItemDataList objectAtIndex:indexPath.row];
    [cell loadItemData:itemData];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBActivityData* itemData = [self.cellItemDataList objectAtIndex:indexPath.row];
    [self performSelector:@selector(showDetails:) withObject:itemData];
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
    
    [self reloadCellItemDataList];
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    [self loadMoreCellItemDataList];
}

- (CBActivityData*)fetchLastItemData {
    CBActivityData* itemData = nil;
    for (CBActivityData* item in _cellItemDataList) {
        if (itemData == nil) {
            itemData = item;
        }
        else {
            if (itemData.uid < item.uid) {
                itemData = item;
            }
        }
    }
    
    return itemData;
}

#pragma mark - Private
- (void)showDetails:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti.open.activity" object:sender];
}

- (void)reloadCellItemDataList {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [_cellItemDataList removeAllObjects];
        
        for (NSDictionary* json in dataJson) {
            CBActivityData* itemData = [CBActivityData instanceWithDictionary:json];
            if (itemData) {
                [_cellItemDataList addObject:itemData];
            }
        }
        
        self.tableview.pullLastRefreshDate = [NSDate date];
        self.tableview.pullTableIsRefreshing = NO;
        
        [self.tableview reloadData];
        [gApp hideAlert];
        
        if (_cellItemDataList.count == 0) {
            [gApp alert:@"没有更多活动了"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        self.tableview.pullTableIsRefreshing = NO;
        [gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        [gApp.engine.httpClient reqGetActivityListOfKindergarten:gApp.engine.loginInfo.schoolId
                                                 from:-1
                                                   to:-1
                                                 most:-1
                                              success:sucessHandler
                                              failure:failureHandler];
    }
    else {
        [gApp alert:@"没有宝宝数据"];
    }
}

- (void)loadMoreCellItemDataList {
    CBActivityData* lastItemData = [self fetchLastItemData];
    if (lastItemData) {
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSMutableArray* tmpItemDataList = [NSMutableArray array];
            for (id itemJson in dataJson) {
                CBActivityData* itemData = [CBActivityData instanceWithDictionary:itemJson];
                if (itemData) {
                    [tmpItemDataList addObject:itemData];
                }
            }
            
            if (tmpItemDataList.count > 0) {
                [_cellItemDataList addObjectsFromArray:tmpItemDataList];
                [gApp hideAlert];
            }
            else {
                [gApp alert:@"没有更多活动了"];
            }
            
            self.tableview.pullTableIsLoadingMore = NO;
            [self.tableview reloadData];
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            self.tableview.pullTableIsLoadingMore = NO;
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp.engine.httpClient reqGetActivityListOfKindergarten:gApp.engine.loginInfo.schoolId
                                                 from:lastItemData.uid
                                                   to:-1
                                                 most:25
                                              success:sucessHandler
                                              failure:failureHandler];
    }
    else {
        [self reloadCellItemDataList];
    }
}

@end

//
//  CBContractorMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBContractorMainViewController.h"
#import "PullTableView.h"
#import "CSAppDelegate.h"
#import "CBContractorData.h"
#import "CBContractorItemCell.h"

@interface CBContractorMainViewController ()  <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
@property (weak, nonatomic) IBOutlet PullTableView *tableview;
@property (nonatomic, strong) NSMutableArray* cellItemDataList;
@property (nonatomic, assign) NSInteger category;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnGame;
@property (weak, nonatomic) IBOutlet UIButton *btnEdu;
@property (weak, nonatomic) IBOutlet UIButton *btnShop;
@property (weak, nonatomic) IBOutlet UIButton *btnOther;
- (IBAction)onBtnContactorTypeClicked:(id)sender;

@end

@implementation CBContractorMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    
    self.tableview.pullDelegate = self;
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    _cellItemDataList = [NSMutableArray array];
    self.category = kContractorTypePhoto;
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
        [self refreshTable];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellItemDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBContractorItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CBContractorItemCell"];
    CBContractorData* itemData = [self.cellItemDataList objectAtIndex:indexPath.row];
    [cell loadItemData:itemData];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 83;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBContractorData* itemData = [self.cellItemDataList objectAtIndex:indexPath.row];
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

- (CBContractorData*)fetchLastItemData {
    CBContractorData* itemData = nil;
    for (CBContractorData* item in _cellItemDataList) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti.open.contractor" object:sender];
}

- (void)reloadCellItemDataList {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [_cellItemDataList removeAllObjects];
        
        for (NSDictionary* json in dataJson) {
            CBContractorData* itemData = [CBContractorData instanceWithDictionary:json];
            if (itemData) {
                [_cellItemDataList addObject:itemData];
            }
        }
        
        self.tableview.pullLastRefreshDate = [NSDate date];
        self.tableview.pullTableIsRefreshing = NO;
        
        [self.tableview reloadData];
        [gApp hideAlert];
        
        if (_cellItemDataList.count == 0) {
            [gApp alert:@"没有更多商户了"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        self.tableview.pullTableIsRefreshing = NO;
        [gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        //[gApp waitingAlert:@"正在获取数据"];
        [gApp.engine reqGetContractorListOfKindergarten:gApp.engine.loginInfo.schoolId
                                           withCategory:self.category
                                                   from:-1
                                                     to:-1
                                                   most:-1
                                                success:sucessHandler
                                                failure:failureHandler];
    }
    else {
        [gApp alert:@"没有更多商户了"];
    }
}

- (void)loadMoreCellItemDataList {
    CBContractorData* lastItemData = [self fetchLastItemData];
    if (lastItemData) {
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSMutableArray* tmpItemDataList = [NSMutableArray array];
            for (id itemJson in dataJson) {
                CBContractorData* itemData = [CBContractorData instanceWithDictionary:itemJson];
                if (itemData) {
                    [tmpItemDataList addObject:itemData];
                }
            }
            
            if (tmpItemDataList.count > 0) {
                [_cellItemDataList addObjectsFromArray:tmpItemDataList];
                [gApp hideAlert];
            }
            else {
                [gApp alert:@"没有更多商户了"];
            }
            
            self.tableview.pullTableIsLoadingMore = NO;
            [self.tableview reloadData];
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            self.tableview.pullTableIsLoadingMore = NO;
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp.engine reqGetContractorListOfKindergarten:gApp.engine.loginInfo.schoolId
                                           withCategory:self.category
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

- (IBAction)onBtnContactorTypeClicked:(id)sender {
    if ([sender isEqual:self.btnPhoto]) {
        self.category = kContractorTypePhoto;
    }
    else if ([sender isEqual:self.btnGame]) {
        self.category = kContractorTypeGame;
    }
    else if ([sender isEqual:self.btnEdu]) {
        self.category = kContractorTypeEducation;
    }
    else if ([sender isEqual:self.btnShop]) {
        self.category = kContractorTypeShop;
    }
    else if ([sender isEqual:self.btnOther]) {
        self.category = kContractorTypeOther;
    }
    
    [self refreshTable];
}

@end

//
//  CSKuleHistoryListTableViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-12.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryListTableViewController.h"
#import "CSAppDelegate.h"
#import "CSKuleHistoryItemTableViewCell.h"

@interface CSKuleHistoryListTableViewController () {
    NSMutableArray* _historyList;
}

@end

@implementation CSKuleHistoryListTableViewController
@synthesize year = _year;
@synthesize month = _month;

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self customizeBackBarItem];
    [self customizeOkBarItemWithTarget:self action:@selector(onBtnRefreshClicked:) text:@"刷新"];
    
    [self doReloadHistory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSKuleHistoryItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleHistoryItemTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    CSKuleHistoryInfo* historyInfo = [_historyList objectAtIndex:indexPath.row];
    cell.historyInfo = historyInfo;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleHistoryInfo* historyInfo = [_historyList objectAtIndex:indexPath.row];
    CGFloat height = [CSKuleHistoryItemTableViewCell calcHeight:historyInfo];
    return height;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onBtnRefreshClicked:(id)sender {
    
}

- (void)doReloadHistory {
    NSString* fromDateString = [NSString stringWithFormat:@"%d-%d-01 00:00:00", _year, _month];
    NSString* toDateString = [NSString stringWithFormat:@"%d-%d-01 00:00:00", _year, _month+1];
    
    if (_month >= 12) {
        fromDateString = [NSString stringWithFormat:@"%d-12-01 00:00:00", _year];
        toDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", _year+1];
    }
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate* fromDate = [fmt dateFromString:fromDateString];
    NSDate* toDate = [fmt dateFromString:toDateString];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        /*
         {
         content = "\U6d4b\U8bd5\U770b\U7f51\U9875\U663e\U793a\U95ee\U9898";
         id = 796;
         medium =     (
         {
         type = image;
         url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_180338.jpg";
         },
         {
         type = image;
         url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_145407.jpg";
         }
         );
         sender =     {
         id = "3_2088_1403762507321";
         type = t;
         };
         timestamp = 1406449306043;
         topic = "2_2088_900";
         },
         */
        
        _historyList = [NSMutableArray array];
        
        for (id obj in dataJson) {
            id historyInfo = [CSKuleInterpreter decodeHistoryInfo:obj];
            if (historyInfo) {
                [_historyList addObject:historyInfo];
            }
        }
        
        [self.tableView reloadData];
        
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
    };
    
    [gApp waitingAlert:@"获取数据中" withTitle:@"请稍候"];
    
    [gApp.engine reqGetHistoryListOfKindergarten:gApp.engine.loginInfo.schoolId
                                     withChildId:gApp.engine.currentRelationship.child.childId
                                        fromDate:fromDate
                                          toDate:toDate
                                         success:sucessHandler
                                         failure:failureHandler];
}

@end

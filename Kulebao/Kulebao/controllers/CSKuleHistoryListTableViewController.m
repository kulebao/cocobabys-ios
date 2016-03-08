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
#import "CSKuleHistoryVideoItemTableViewCell.h"
#import "EntityHistoryInfoHelper.h"
#import "EntitySenderInfo.h"
#import "EntityHistoryInfoHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

@interface CSKuleHistoryListTableViewController () <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController* _frCtrl;
    NSIndexPath* _denyIndexPath;
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
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    _frCtrl = [EntityHistoryInfoHelper frCtrlForYear:_year month:_month topic:currentChild.childId];
    _frCtrl.delegate = self;
    NSError* error = nil;
    [_frCtrl performFetch:&error];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    [self doReloadHistory];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNoti:)
                                                 name:@"noti.video"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    //[self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    return _frCtrl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* baseCell = nil;
    EntityHistoryInfo* historyInfo = [_frCtrl objectAtIndexPath:indexPath];

    
    if ([self isVideoItem:historyInfo]) {
        CSKuleHistoryVideoItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleHistoryVideoItemTableViewCell" forIndexPath:indexPath];
        cell.historyInfo = historyInfo;
        cell.delegate = self;
        baseCell = cell;
    }
    else {
        CSKuleHistoryItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleHistoryItemTableViewCell" forIndexPath:indexPath];
        
        // Configure the cell...
        cell.historyInfo = historyInfo;
        cell.delegate = self;
        baseCell = cell;
    }
    
    return baseCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    EntityHistoryInfo* historyInfo = [_frCtrl objectAtIndexPath:indexPath];
    if ([self isVideoItem:historyInfo]) {
        height = [CSKuleHistoryVideoItemTableViewCell calcHeight:historyInfo
                                                           width:tableView.bounds.size.width];
    }
    else {
        height = [CSKuleHistoryItemTableViewCell calcHeight:historyInfo
                                                      width:tableView.bounds.size.width];
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)historyItemTableCellDidLongPress:(CSKuleHistoryItemTableViewCell*)cell {
    [self showDeleteMenu:cell];
}

- (void)historyVideoItemTableCellDidLongPress:(CSKuleHistoryVideoItemTableViewCell*)cell {
    [self showDeleteMenu:cell];
}

- (void)showDeleteMenu:(UITableViewCell*)cell {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    _denyIndexPath = indexPath;
    UIMenuItem *flag = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteCell:)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:flag, nil]];
    [menu setTargetRect:cell.frame inView:cell.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (void)deleteCell:(id)sender {
    if (_denyIndexPath) {
        EntityHistoryInfo* historyInfo = [_frCtrl objectAtIndexPath:_denyIndexPath];
        
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
            NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
            if (error_code == 0) {
                [EntityHistoryInfoHelper deleteEntity:historyInfo];
                [gApp hideAlert];
            }
            else {
                [gApp alert:error_msg];
            }
            
            _denyIndexPath = nil;
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            _denyIndexPath = nil;
            CSLog(@"failure:%@", error);
            [gApp hideAlert];
        };
        
        [gApp waitingAlert:@"请稍等"];
        [gApp.engine.httpClient reqDeleteHistoryOfKindergarten:gApp.engine.loginInfo.schoolId
                                        withChildId:gApp.engine.currentRelationship.child.childId
                                           recordId:historyInfo.uid.longLongValue
                                            success:sucessHandler
                                            failure:failureHandler];
    }
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}

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
}

- (void)onBtnRefreshClicked:(id)sender {
    [self doReloadHistory];
}

- (void)doReloadHistory {
    NSString* fromDateString = [NSString stringWithFormat:@"%ld-%ld-01 00:00:00", (long)_year, (long)_month];
    NSString* toDateString = [NSString stringWithFormat:@"%ld-%ld-01 00:00:00", (long)_year, _month+1];
    
    if (_month >= 12) {
        fromDateString = [NSString stringWithFormat:@"%ld-12-01 00:00:00", (long)_year];
        toDateString = [NSString stringWithFormat:@"%ld-01-01 00:00:00", _year+1];
    }
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate* fromDate = [fmt dateFromString:fromDateString];
    NSDate* toDate = [fmt dateFromString:toDateString];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSArray* historyList = [EntityHistoryInfoHelper updateEntities:dataJson];
        
        if (historyList.count == 0) {
            [gApp shortAlert:@"没有新的数据"];
        }
        else {
            [gApp hideAlert];
        }
        
        [self.tableView reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
    };
    
    [gApp waitingAlert:@"获取数据中" withTitle:@"请稍候"];
    
    [gApp.engine.httpClient reqGetHistoryListOfKindergarten:gApp.engine.loginInfo.schoolId
                                     withChildId:gApp.engine.currentRelationship.child.childId
                                        fromDate:fromDate
                                          toDate:toDate
                                         success:sucessHandler
                                         failure:failureHandler];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView* aTableView = self.tableView;
    
    if (aTableView) {
        switch (type) {
            case NSFetchedResultsChangeUpdate:
                [aTableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                [aTableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationBottom];
                [aTableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
                break;
            case NSFetchedResultsChangeDelete:
                [aTableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationBottom];
                break;
            case NSFetchedResultsChangeInsert:
                [aTableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (BOOL)isVideoItem:(EntityHistoryInfo*)historyInfo {
    BOOL ret = NO;
    if (historyInfo.medium.count == 1) {
        CSKuleMediaInfo* media = [historyInfo.medium firstObject];
        ret = [media.type isEqualToString:@"video"];
    }
    
    return ret;
}

- (void)playFullScreen:(NSURL*)videoURL {
    if (videoURL) {
        MPMoviePlayerViewController* ctrl = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];

        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"v2-btn_blue.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(saveVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        objc_setAssociatedObject(btn, "videoUrl", videoURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(btn, "playerCtrl", ctrl, OBJC_ASSOCIATION_ASSIGN);
        
        btn.frame = CGRectMake(0, 0, 70, 32);
        btn.center = CGPointMake(self.view.bounds.size.width/2, 70);
        [ctrl.view addSubview:btn];
        [self presentMoviePlayerViewControllerAnimated:ctrl];
    }
}

- (void)onNoti:(NSNotification*)noti {
    [self playFullScreen:noti.object];
}

- (void)saveVideo:(id)sender {
    NSURL* videoURL = objc_getAssociatedObject(sender, "videoUrl");
    MPMoviePlayerViewController* ctrl = objc_getAssociatedObject(sender, "playerCtrl");
    BOOL ok = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.path);
    if (videoURL && ok) {
        [gApp waitingAlert:@"保存中，请稍候..."];
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path,
                                            self,
                                            @selector(video:didFinishSavingWithError:contextInfo:),
                                            nil);
    }
    else {
        [gApp alert:@"无效的视频"];
    }
}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        [gApp shortAlert:@"保存失败"];
    }
    else {
        [gApp shortAlert:@"保存成功"];
    }
}

@end

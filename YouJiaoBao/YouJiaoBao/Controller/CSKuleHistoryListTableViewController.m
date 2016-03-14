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
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CBHistoryInfo.h"
#import "PullTableView.h"
#import "CSStudentListPickUpTableViewController.h"
#import "CSContentEditorViewController.h"
#import "EGOCache.h"

@interface CSKuleHistoryListTableViewController () <NSFetchedResultsControllerDelegate, PullTableViewDelegate> {
    NSIndexPath* _denyIndexPath;
    
    NSMutableArray* _imageUrlList;
    NSMutableArray* _imageList;
    NSString* _videoUrl;
    NSURL* _videoFileUrl;
    NSString* _textContent;
    NSArray* _childList;
}

@property (nonatomic, strong) NSMutableArray* historyList;
@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

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
    //[self customizeBackBarItem];
    //[self customizeOkBarItemWithTarget:self action:@selector(onBtnRefreshClicked:) text:@"刷新"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onPostNewHistory:)];
    
    self.pullTableView.pullDelegate = self;
    self.pullTableView.pullBackgroundColor = [UIColor clearColor];
    self.pullTableView.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
   // _frCtrl.delegate = self;
   // NSError* error = nil;
   // [_frCtrl performFetch:&error];
    self.historyList = [NSMutableArray array];
    
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

- (void)onPostNewHistory:(id)sender {
    [self performSegueWithIdentifier:@"segue.main.growexp" sender:nil];
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
    return self.historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* baseCell = nil;
    CBHistoryInfo* historyInfo = [self.historyList objectAtIndex:indexPath.row];

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
    CBHistoryInfo* historyInfo = [self.historyList objectAtIndex:indexPath.row];
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
        CBHistoryInfo* historyInfo = [self.historyList objectAtIndex:_denyIndexPath.row];
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
            NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
            if (error_code == 0) {
                [self.historyList removeObject:historyInfo];
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
        
        /*
        [gApp waitingAlert:@"请稍等"];
        CSHttpClient* http = [CSHttpClient sharedInstance];
        [gApp.engine.httpClient reqDeleteHistoryOfKindergarten:gApp.engine.loginInfo.schoolId
                                        withChildId:gApp.engine.currentRelationship.child.childId
                                           recordId:historyInfo.uid.longLongValue
                                            success:sucessHandler
                                            failure:failureHandler];
         */
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
    if ([segue.identifier isEqualToString:@"segue.main.growexp"]) {
        CSContentEditorViewController* ctrl = segue.destinationViewController;
        ctrl.delegate = self;
        ctrl.navigationItem.title = @"成长经历";
    }
    else if ([segue.identifier isEqualToString:@"segue.main.studentpickup"]) {
        CSStudentListPickUpTableViewController* ctrl = segue.destinationViewController;
        ctrl.delegate = self;
    }
}

- (void)onBtnRefreshClicked:(id)sender {
    [self doReloadHistory];
}

- (void)doReloadHistory {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [self.historyList removeAllObjects];
        for (NSDictionary* historyDict in dataJson) {
            [self.historyList addObject:[CBHistoryInfo instanceWithDictionary:historyDict]];
            [self processDataList];
        }
        
        if (self.historyList.count == 0) {
            [gApp alert:@"没有新的数据"];
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
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    [http reqGetHistoryList:engine.loginInfo.o_id
             inKindergarten:engine.loginInfo.schoolId.integerValue
                       from:nil
                         to:nil
                       most:nil
                    success:sucessHandler
                    failure:failureHandler];
}

- (BOOL)isVideoItem:(CBHistoryInfo*)historyInfo {
    BOOL ret = NO;
    if (historyInfo.medium.count == 1) {
        CBMediaInfo* media = [historyInfo.medium firstObject];
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
        [gApp alert:@"保存失败"];
    }
    else {
        [gApp alert:@"保存成功"];
    }
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
    
    [self reloadDataList];
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    [self loadMoreDataList];
}

#pragma mark - Private
- (void)reloadAllDataList {
}

- (void)reloadDataList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
        

        NSMutableArray* newObjList = [NSMutableArray array];
        for (NSDictionary* historyDict in responseObject) {
            [newObjList addObject:[CBHistoryInfo instanceWithDictionary:historyDict]];
        }
        
        if (newObjList.count == 0) {
            [gApp alert:@"已是最新"];
        }
        else {
            
            [self.historyList addObjectsFromArray:newObjList];
            [self processDataList];
            
            [gApp hideAlert];
            [self.pullTableView reloadData];
        }
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
    };
    
    CBHistoryInfo* first = self.historyList.lastObject;
    
    [http reqGetHistoryList:engine.loginInfo.o_id
             inKindergarten:engine.loginInfo.schoolId.integerValue
                       from:first.timestamp
                         to:nil
                       most:@(50)
                    success:success
                    failure:failure];
}

- (void)loadMoreDataList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        self.pullTableView.pullTableIsLoadingMore = NO;
        
        NSMutableArray* newObjList = [NSMutableArray array];
        for (NSDictionary* historyDict in responseObject) {
            [newObjList addObject:[CBHistoryInfo instanceWithDictionary:historyDict]];
        }
        
        if (newObjList.count == 0) {
            [gApp alert:@"没有更多公告了"];
        }
        else {
            
            [self.historyList addObjectsFromArray:newObjList];
            [self processDataList];
            
            [gApp hideAlert];
            [self.pullTableView reloadData];
        }
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        self.pullTableView.pullTableIsLoadingMore = NO;
    };
    
    CBHistoryInfo* last = self.historyList.lastObject;
    
    [http reqGetHistoryList:engine.loginInfo.o_id
             inKindergarten:engine.loginInfo.schoolId.integerValue
                       from:nil
                         to:last.timestamp
                       most:@(50)
                    success:success
                    failure:failure];
}


- (void)processDataList {
    NSMutableSet<NSNumber*>* timestamps = [NSMutableSet<NSNumber*> set];
    
    NSMutableArray* copyList = [self.historyList copy];
    [self.historyList removeAllObjects];
    
    for (CBHistoryInfo* obj in copyList) {
        if (![timestamps containsObject:obj.timestamp]) {
            [self.historyList addObject:obj];
            [timestamps addObject:obj.timestamp];
        }
        else {
            
        }
    }
    
    
    [self.historyList sortUsingComparator:^NSComparisonResult(CBHistoryInfo* obj1, CBHistoryInfo* obj2) {
        NSComparisonResult ret = [obj2.timestamp compare:obj1.timestamp];
        return ret;
    }];
}

#pragma mark - CSContentEditorViewControllerDelegate
- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl
                     finishEditText:(NSString*)text
                         withImages:(NSArray*)imageList {
    _textContent = [text trim];
    _imageUrlList = [NSMutableArray array];
    _imageList = [NSMutableArray arrayWithArray:imageList];
    _videoFileUrl = nil;
    _videoUrl = nil;
    
    [self performSegueWithIdentifier:@"segue.main.studentpickup" sender:nil];
}

- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl
                     finishEditText:(NSString*)text
                          withVideo:(NSURL*)videoLocalUrl {
    _textContent = [text trim];
    _imageUrlList = [NSMutableArray array];
    _imageList = [NSMutableArray array];
    _videoFileUrl = videoLocalUrl;
    _videoUrl = nil;
    
    [self performSegueWithIdentifier:@"segue.main.studentpickup" sender:nil];
}

- (void)doUploadVideo {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    NSData* videoData = [NSData dataWithContentsOfURL:_videoFileUrl];
    
    NSString* videoFileName = [NSString stringWithFormat:@"history_video/%@/topic_%@/%@.mp4",
                               engine.loginInfo.schoolId,
                               engine.loginInfo.o_id,
                               @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        _videoUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, videoFileName];
        [[EGOCache globalCache] setData:videoData
                                 forKey:_videoUrl.MD5HashEx
                             completion:^(BOOL ok) {
                                 CSLog(@"Cached video as key %@", _videoUrl.MD5HashEx);
                                 [self doSendHistory];
                             }];
        
        [self doSendHistory];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传视频中"];
    [http opUploadToQiniu:videoData
                  withKey:videoFileName
                 withMime:@""
                  success:sucessHandler
                  failure:failureHandler];
}

- (void)doUploadImage {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    UIImage* img = [_imageList firstObject];
    if (img) {
        NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
        NSString* imgFileName = [NSString stringWithFormat:@"history_img/%@/topic_%@/%@.jpg",
                                 engine.loginInfo.schoolId,
                                 engine.loginInfo.o_id,
                                 @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
        
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSString* imgUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, imgFileName];
            CSLog(@"Uploaded:%@", imgUrl);
            [_imageUrlList addObject:imgUrl];
            [_imageList removeObjectAtIndex:0];
            
            [self performSelectorInBackground:@selector(doUploadImage) withObject:nil];
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp waitingAlert:@"上传图片中"];
        
        [http opUploadToQiniu:imgData
                      withKey:imgFileName
                     withMime:@"image/jpeg"
                      success:sucessHandler
                      failure:failureHandler];
    }
    else {
        [self doSendHistory];
    }
}

- (void)doSendHistory {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [gApp alert:@"提交成功"];
        [self.navigationController popToViewController:self animated:YES];
        [self doReloadHistory];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    NSMutableArray* childIdList = [NSMutableArray array];
    for (EntityChildInfo* childInfo in _childList) {
        [childIdList addObject:childInfo.childId];
    }
    
    if (childIdList.count > 0) {
        [gApp waitingAlert:@"提交数据中"];
        [http opPostHistoryOfKindergarten:engine.loginInfo.schoolId.integerValue
                             withSenderId:engine.loginInfo.o_id
                          withChildIdList:childIdList
                              withContent:_textContent
                         withImageUrlList:_imageUrlList
                             withVideoUrl:_videoUrl
                                  success:sucessHandler
                                  failure:failureHandler];
    }
    else {
        [gApp alert:@"请选择发布对象"];
    }
}

#pragma mark - CSStudentListPickUpTableViewControllerDelegate
- (void)studentListPickUpTableViewController:(CSStudentListPickUpTableViewController*)ctrl
                                   didPickUp:(NSArray*)childList {
    _childList = childList;
    if (_childList.count == 0) {
        [gApp alert:@"必须选择至少一个小孩"];
    }
    else if (_videoFileUrl) {
        [self doUploadVideo];
    }
    else if (_imageList.count > 0) {
        [self doUploadImage];
    }
    else {
        [self doSendHistory];
    }
}

@end

//
//  CSNoticeTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSNoticeTableViewController.h"
#import "PullTableView.h"
#import "CSNoticeItemTableViewCell.h"
#import "CSAppDelegate.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "EntityClassInfo.h"
#import "EntityNewsInfoHelper.h"
#import "CSNewsInfoDetailViewController.h"
#import "CSContentEditorViewController.h"
#import "UIViewController+CSKit.h"

@interface CSNoticeTableViewController () <PullTableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController* _frCtrl;
    
    NSMutableArray* _imageUrlList;
    NSMutableArray* _imageList;
    NSString* _textContent;
    NSString* _textTitle;
}

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

@end

@implementation CSNoticeTableViewController

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
    
    [self customizeOkBarItemWithTarget:self action:@selector(onSendNotice:) text:@"发布"];
    
    self.pullTableView.pullDelegate = self;
    self.pullTableView.pullBackgroundColor = [UIColor clearColor];
    self.pullTableView.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    CSEngine* engine = [CSEngine sharedInstance];
    NSArray* classInfoList = engine.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (EntityClassInfo* classInfo in classInfoList) {
        [classIdList addObject:classInfo.classId.stringValue];
    }
    
    _frCtrl = [EntityNewsInfoHelper frNewsWithClassList:classIdList
                                         ofKindergarten:engine.loginInfo.schoolId.integerValue];
    _frCtrl.delegate = self;
    
    NSError* error = nil;
    if (![_frCtrl performFetch:&error]) {
        CSLog(@"frNewsWithClassList Error: %@", error);
    }
    
    [self reloadNewsList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSendNotice:(id)sender {
    [self performSegueWithIdentifier:@"segue.news.create" sender:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
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
    CSNoticeItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSNoticeItemTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    EntityNewsInfo* newsInfo = [_frCtrl objectAtIndexPath:indexPath];
    cell.newsInfo = newsInfo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EntityNewsInfo* newsInfo = [_frCtrl objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"segue.news.detail" sender:newsInfo];
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
    if ([segue.identifier isEqualToString:@"segue.news.detail"]) {
        CSNewsInfoDetailViewController* ctrl = segue.destinationViewController;
        ctrl.newsInfo = sender;
    }
    else if ([segue.identifier isEqualToString:@"segue.news.create"]) {
        CSContentEditorViewController* ctrl = segue.destinationViewController;
        ctrl.navigationItem.title = @"发布园内公告";
        ctrl.delegate = self;
    }
}

#pragma mark - CSContentEditorViewControllerDelegate
- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl
                     finishEditText:(NSString*)text
                          withTitle:(NSString*)title
                         withImages:(NSArray*)imageList {
    _textContent = text;
    _textTitle = title;
    _imageUrlList = [NSMutableArray array];
    _imageList = [NSMutableArray arrayWithArray:imageList];
    
    if (_imageList.count > 0) {
        [self doUploadImage];
    }
    else {
        [self doSendSubmit];
    }
    
}

- (void)doUploadImage {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    UIImage* img = [_imageList firstObject];
    if (img) {
        NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
        NSString* imgFileName = [NSString stringWithFormat:@"news_img/%@/t_%@/%@.jpg",
                                 engine.loginInfo.schoolId,
                                 engine.loginInfo.uid,
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
        [self doSendSubmit];
    }
}

- (void)doSendSubmit {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [gApp alert:@"提交成功"];
        [self.navigationController popToViewController:self animated:YES];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"提交数据中"];
    
    [http opPostNewsOfKindergarten:engine.loginInfo.schoolId.integerValue
                    withSenderName:engine.loginInfo.name
                       withClassId:@(0)
                       withContent:_textContent
                         withTitle:_textTitle
                  withImageUrlList:_imageUrlList
                           success:sucessHandler
                           failure:failureHandler];
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

#pragma mark - Private
- (void)reloadNewsList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    NSArray* classInfoList = engine.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (EntityClassInfo* classInfo in classInfoList) {
        [classIdList addObject:classInfo.classId.stringValue];
    }
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* list = [EntityNewsInfoHelper updateEntities: responseObject];
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
        
        if (list.count == 0) {
            [app alert:@"已是最新"];
        }
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
    };
    
    EntityNewsInfo* lastestNewsInfo = [_frCtrl.fetchedObjects firstObject];
    
    [http opGetNewsOfClasses:classIdList
              inKindergarten:engine.loginInfo.schoolId.integerValue
                        from:lastestNewsInfo.timestamp
                          to:nil
                        most:nil
                     success:success
                     failure:failure];
}

- (void)loadMoreNewsList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    NSArray* classInfoList = engine.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (EntityClassInfo* classInfo in classInfoList) {
        [classIdList addObject:classInfo.classId.stringValue];
    }
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* list = [EntityNewsInfoHelper updateEntities: responseObject];
        
        self.pullTableView.pullTableIsLoadingMore = NO;
        
        if (list.count == 0) {
            [app alert:@"没有更多公告了"];
        }
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        self.pullTableView.pullTableIsLoadingMore = NO;
    };
    
    EntityNewsInfo* earliestNewsInfo = [_frCtrl.fetchedObjects lastObject];
    
    [http opGetNewsOfClasses:classIdList
              inKindergarten:engine.loginInfo.schoolId.integerValue
                        from:nil
                          to:earliestNewsInfo.timestamp
                        most:nil
                     success:success
                     failure:failure];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView* aTableView = self.pullTableView;
    
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
    [self.pullTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.pullTableView endUpdates];
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return nil;
}

@end

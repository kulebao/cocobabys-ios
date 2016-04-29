//
//  CSNoticeTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSNoticeTableViewController.h"
#import "PullTableView.h"
#import "CSKuleNewsTableViewCell.h"
#import "CSAppDelegate.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CSNewsInfoDetailViewController.h"
#import "UIViewController+CSKit.h"
#import "CSPopupController.h"
#import "CSClassPickerView.h"
#import "CSCreateNoticeViewController.h"

@interface CSNoticeTableViewController () <PullTableViewDelegate, CSCreateNoticeViewControllerDelegate > {
    
    NSMutableArray* _imageUrlList;
    NSMutableArray* _imageList;
    NSString* _textContent;
    NSString* _textTitle;
    BOOL _requriedFeedback;
    NSArray* _tags;
    NSNumber* _classId;
    
    NSArray* _newsInfoList;
}

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

@property (nonatomic, strong) CSPopupController* popCtrl;
@property (nonatomic, strong) CSClassPickerView* classPickerView;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(onSendNotice:)];
    
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    self.popCtrl = [CSPopupController popupControllerWithView:gApp.window];
    
    self.classPickerView = [CSClassPickerView defaultClassPickerView];
    self.classPickerView.delegate = self;
    self.classPickerView.canSelectAll = session.allowToSendAll;
    
    self.pullTableView.pullDelegate = self;
    self.pullTableView.pullBackgroundColor = [UIColor clearColor];
    self.pullTableView.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];

    [self.pullTableView registerNib:[UINib nibWithNibName:@"CSKuleNewsTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"CSKuleNewsTableViewCell"];
    
    [self reloadAllNewsList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSendNotice:(id)sender {
    [self performSegueWithIdentifier:@"segue.createnotice" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    _newsInfoList = [session.newsInfoList copy];
    [self.tableView reloadData];
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
    return _newsInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSKuleNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNewsTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    CBNewsInfo* newsInfo = [_newsInfoList objectAtIndex:indexPath.row];
    [cell loadNewsInfo:newsInfo];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBNewsInfo* newsInfo = [_newsInfoList objectAtIndex:indexPath.row];
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
    else if ([segue.identifier isEqualToString:@"segue.createnotice"]) {
        CSCreateNoticeViewController* ctrl = segue.destinationViewController;
        ctrl.navigationItem.title = @"发布公告";
        ctrl.delegate = self;
        ctrl.singleImage = YES;
    }
}

#pragma mark - CSCreateNoticeViewControllerDelegate
- (void)createNoticeViewController:(CSCreateNoticeViewController*)ctrl
                     finishEditText:(NSString*)text
                          withTitle:(NSString*)title
                         withImages:(NSArray*)imageList
                          withTags:(NSArray *)tags
                  requriedFeedback:(BOOL)feedback {
    _textContent = text;
    _textTitle = title;
    _imageUrlList = [NSMutableArray array];
    _imageList = [NSMutableArray arrayWithArray:imageList];
    _requriedFeedback = feedback;
    _tags = tags;
 
    [self doSelectClass];
}

- (void)doSelectClass {
    self.classPickerView.center = CGPointMake(gApp.window.bounds.size.width/2, gApp.window.bounds.size.height/2);
    
    [self.classPickerView reset];
    [self.popCtrl presentView:self.classPickerView animated:NO completion:^{
        
    }];
}

#pragma mark - CSClassPickerViewDelegate
- (void)classPickerViewDidOk:(CSClassPickerView*)view withClassId:(NSNumber *)classId{
    [self.popCtrl dismiss];
    
    _classId = classId;
    if (_classId) {
        if (_imageList.count > 0) {
            [self doUploadImage];
        }
        else {
            [self doSendSubmit];
        }
    }
}

- (void)classPickerViewDidCancel:(CSClassPickerView*)view {
    [self.popCtrl dismiss];
}

- (void)doUploadImage {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    UIImage* img = [_imageList firstObject];
    if (img) {
        NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
        NSString* imgFileName = [NSString stringWithFormat:@"news_img/%@/t_%@/%@.jpg",
                                 session.loginInfo.school_id,
                                 session.loginInfo._id,
                                 @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
        
        SuccessResponseHandler sucessHandler = ^(NSURLSessionDataTask *task, id dataJson) {
            NSString* imgUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, imgFileName];
            CSLog(@"Uploaded:%@", imgUrl);
            [_imageUrlList addObject:imgUrl];
            [_imageList removeObjectAtIndex:0];
            
            [self performSelectorInBackground:@selector(doUploadImage) withObject:nil];
        };
        
        FailureResponseHandler failureHandler = ^(NSURLSessionDataTask *task, NSError *error) {
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
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    SuccessResponseHandler sucessHandler = ^(NSURLSessionDataTask *task, id dataJson) {
        [gApp alert:@"提交成功"];
        [self.navigationController popToViewController:self animated:YES];
        
        [self reloadNewsList];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLSessionDataTask *task, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"提交数据中"];
    
    [http opPostNewsOfKindergarten:session.loginInfo.school_id.integerValue
                        withSender:session.loginInfo
                       withClassId:_classId
                       withContent:_textContent
                         withTitle:_textTitle
                  withImageUrlList:_imageUrlList
                          withTags:_tags
              withRequriedFeedback:_requriedFeedback
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
- (void)reloadAllNewsList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    NSArray* classInfoList = session.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (CBClassInfo* classInfo in classInfoList) {
        [classIdList addObject:[@(classInfo.class_id) stringValue]];
    }
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        [session reloadNewsInfosByJsonObject:responseObject];
        _newsInfoList = [session.newsInfoList copy];
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
        
        if ([responseObject count] == 0) {
            //[app alert:@"已是最新"];
        }
        else {
            [self.pullTableView reloadData];
        }
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
    };
    
    [http opGetNewsOfClasses:classIdList
              inKindergarten:session.loginInfo.school_id.integerValue
                        from:nil
                          to:nil
                        most:@(50)
                     success:success
                     failure:failure];
}

- (void)reloadNewsList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    NSArray* classInfoList = session.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (CBClassInfo* classInfo in classInfoList) {
        [classIdList addObject:[@(classInfo.class_id) stringValue]];
    }
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        [session updateNewsInfosByJsonObject:responseObject];
        _newsInfoList = [session.newsInfoList copy];
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
        
        if ([responseObject count] == 0) {
            [app alert:@"已是最新"];
        }
        else {
            [self.pullTableView reloadData];
        }
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        self.pullTableView.pullLastRefreshDate = [NSDate date];
        self.pullTableView.pullTableIsRefreshing = NO;
    };
    
    CBNewsInfo* lastestNewsInfo = session.newsInfoList.firstObject;
    [http opGetNewsOfClasses:classIdList
              inKindergarten:session.loginInfo.school_id.integerValue
                        from:lastestNewsInfo.timestamp
                          to:nil
                        most:nil
                     success:success
                     failure:failure];
}

- (void)loadMoreNewsList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    NSArray* classInfoList = session.classInfoList;
    
    NSMutableArray* classIdList = [NSMutableArray array];
    for (CBClassInfo* classInfo in classInfoList) {
        [classIdList addObject:[@(classInfo.class_id) stringValue]];
    }
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        [session updateNewsInfosByJsonObject:responseObject];
        self.pullTableView.pullTableIsLoadingMore = NO;
        
        if ([responseObject count] == 0) {
            [app alert:@"没有更多公告了"];
        }
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        
        self.pullTableView.pullTableIsLoadingMore = NO;
    };
    
    CBNewsInfo* earliestNewsInfo = session.newsInfoList.lastObject;
    
    [http opGetNewsOfClasses:classIdList
              inKindergarten:session.loginInfo.school_id.integerValue
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

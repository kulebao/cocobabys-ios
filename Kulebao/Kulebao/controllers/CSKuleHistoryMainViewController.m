//
//  CSKuleHistoryMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-12.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryMainViewController.h"
#import "CSKuleHistoryMonthCell.h"
#import "CSKuleHistoryListTableViewController.h"
#import "CSAppDelegate.h"
#import "EntityHistoryInfoHelper.h"
#import "EntityMediaInfoHelper.h"
#import "UIImageView+WebCache.h"
#import "CSContentEditorViewController.h"
#import "TSFileCache.h"
#import "NSString+XHMD5.h"
#import "EGOCache.h"

@interface CSKuleHistoryMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSInteger _year;
    
    NSMutableArray* _imageUrlList;
    NSMutableArray* _imageList;
    NSString* _historyContent;
    NSString* _videoUrl;
    NSURL* _videoFileUrl;
}
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSCalendar* calendar;

- (IBAction)onBtnLeftClicked:(id)sender;
- (IBAction)onBtnRightClicked:(id)sender;

@end

@implementation CSKuleHistoryMainViewController

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
    [self customizeOkBarItemWithTarget:self action:@selector(onBtnCreateNewClicked:) text:@"创建"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.calendar = [NSCalendar currentCalendar];
    
    NSDate* now = [NSDate date];
    NSDateComponents* components = [self.calendar components:NSCalendarUnitYear fromDate:now];
    
    _year = components.year;
    self.labTitle.text = [NSString stringWithFormat:@"%d", _year];
}

- (void)viewDidAppear:(BOOL)animated {
    [self doReloadHistory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.history.list"]) {
        NSIndexPath* indexPath = sender;
        CSKuleHistoryListTableViewController* ctrl = segue.destinationViewController;
        ctrl.navigationItem.title = [NSString stringWithFormat:@"%d-%02d", _year, indexPath.row+1];
        ctrl.year = _year;
        ctrl.month = indexPath.row + 1;
    }
    else if ([segue.identifier isEqualToString:@"segue.history.create"]) {
        CSContentEditorViewController* ctrl = segue.destinationViewController;
        ctrl.delegate = self;
    }
}

- (IBAction)onBtnLeftClicked:(id)sender {
    --_year;
    self.labTitle.text = [NSString stringWithFormat:@"%d", _year];
    
    [self doReloadHistory];
}

- (IBAction)onBtnRightClicked:(id)sender {
    ++_year;
    self.labTitle.text = [NSString stringWithFormat:@"%d", _year];
    
    [self doReloadHistory];
}

- (void)onBtnCreateNewClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.history.create" sender:nil];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleHistoryMonthCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSKuleHistoryMonthCell" forIndexPath:indexPath];
    
    cell.labTitle.text = [NSString stringWithFormat:@"%d月", indexPath.row+1];
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    
    EntityMediaInfo* mediaInfo = [EntityHistoryInfoHelper mediaWhereLatestImageOfYear:_year month:indexPath.row+1 topic:currentChild.childId];
    
    [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:mediaInfo.url]
                    placeholderImage:[UIImage imageNamed:@"exp_default.png"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue.history.list" sender:indexPath];
}

- (void)doReloadHistory {
    [self.collectionView reloadData];
}

#pragma mark - CSContentEditorViewControllerDelegate
- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl finishEditText:(NSString*)text withImages:(NSArray*)imageList {
    
    _historyContent = text;
    _imageUrlList = [NSMutableArray array];
    _imageList = [NSMutableArray arrayWithArray:imageList];
    
    if (_imageList.count > 0) {
        [self doUploadImage];
    }
    else {
        [self doSendHistory];
    }
}

- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl
                    finishWithVideo:(NSURL*)videoLocalUrl {
    _videoFileUrl = videoLocalUrl;
    _videoUrl = nil;
    
    if (_videoFileUrl) {
        [self doUploadVideo];
    }
}

- (void)doUploadImage {
    UIImage* img = [_imageList firstObject];
    if (img) {
        NSData* imgData = UIImageJPEGRepresentation(img, 0.8);
        NSString* imgFileName = [NSString stringWithFormat:@"history_img/%@/topic_%@/%@.jpg",
                                 @(gApp.engine.loginInfo.schoolId),
                                 gApp.engine.currentRelationship.child.childId,
                                 @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
        
        SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
            NSString* imgUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, imgFileName];
            [_imageUrlList addObject:imgUrl];
            [_imageList removeObjectAtIndex:0];
            
            TSFileCache* cache = [TSFileCache sharedInstance];
            [cache storeData:imgData
                      forKey:imgUrl.MD5Hash];

            [self performSelectorInBackground:@selector(doUploadImage) withObject:nil];
        };
        
        FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
            CSLog(@"failure:%@", error);
            [gApp alert:[error localizedDescription]];
        };
        
        [gApp waitingAlert:@"上传图片中"];
        [gApp.engine reqUploadToQiniu:imgData
                              withKey:imgFileName
                             withMime:@"image/jpeg"
                              success:sucessHandler
                              failure:failureHandler];
    }
    else {
        [self doSendHistory];
    }
}

- (void)doUploadVideo {
    NSData* videoData = [NSData dataWithContentsOfURL:_videoFileUrl];
    
    NSString* videoFileName = [NSString stringWithFormat:@"history_video/%@/topic_%@/%@.mp4",
                             @(gApp.engine.loginInfo.schoolId),
                             gApp.engine.currentRelationship.child.childId,
                             @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        _videoUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, videoFileName];
        
        [[EGOCache globalCache] setData:videoData
                                 forKey:_videoUrl.MD5HashEx
                             completion:^(BOOL ok) {
                                 CSLog(@"Cached video as key %@", _videoUrl.MD5HashEx);
                                 [self doSendHistory];
        }];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"上传视频中"];
    [gApp.engine reqUploadToQiniu:videoData
                          withKey:videoFileName
                         withMime:@""
                          success:sucessHandler
                          failure:failureHandler];
}

- (void)doSendHistory {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [EntityHistoryInfoHelper updateEntities:@[dataJson]];
        [gApp shortAlert:@"提交成功"];
        [self.navigationController popToViewController:self animated:YES];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"提交数据中"];
    
    [gApp.engine reqPostHistoryOfKindergarten:gApp.engine.loginInfo.schoolId
                                  withChildId:gApp.engine.currentRelationship.child.childId
                                  withContent:_historyContent
                             withImageUrlList:_imageUrlList
                                 withVideoUrl:_videoUrl
                                      success:sucessHandler
                                      failure:failureHandler];
}

@end

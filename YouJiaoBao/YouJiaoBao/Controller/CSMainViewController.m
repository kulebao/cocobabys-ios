//
//  CSMainViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSMainViewController.h"
#import "EntityClassInfoHelper.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CSAppDelegate.h"
#import "CSContentEditorViewController.h"
#import "CSHttpUrls.h"
#import "CSModuleCell.h"
#import "CSStudentListPickUpTableViewController.h"
#import "EntityClassInfo.h"
#import "EntityRelationshipInfoHelper.h"

#define kTestChildId    @"2_2088_900"

@interface CSMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray* _modules;
    
    NSMutableArray* _imageUrlList;
    NSMutableArray* _imageList;
    NSString* _videoUrl;
    NSURL* _videoFileUrl;
    NSString* _textContent;
    NSArray* _childList;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layoutCollectionView;
- (IBAction)onBtnSettingsClicked:(id)sender;

@end

@implementation CSMainViewController

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
    [self.navigationItem setHidesBackButton:YES];
    
    _modules = @[@{@"icon": [UIImage imageNamed:@"v2-校园公告.png"],
                   @"segue": @"segue.main.notice",
                   @"name": @"园内公告"},
                 
                 @{@"icon": [UIImage imageNamed:@"v2-宝宝列表.png"],
                   @"segue": @"segue.main.babylist",
                   @"name": @"宝宝列表"},
                 
                 @{@"icon": [UIImage imageNamed:@"v2-成长经历.png"],
                   @"segue": @"segue.main.growexp",
                   @"name": @"成长经历"},
                 ];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self reloadClassList];
    [self reloadRelationships];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat cellWidth = floor((self.view.bounds.size.width - 40) / 3.0);
    self.layoutCollectionView.itemSize = CGSizeMake(cellWidth, cellWidth);
    [self.collectionView reloadData];
}

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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _modules.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSModuleCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"main.module.cell" forIndexPath:indexPath];
    
    NSDictionary* module = [_modules objectAtIndex:indexPath.row];
    cell.imgBg.image = [module objectForKey:@"icon"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSDictionary* module = [_modules objectAtIndex:indexPath.row];
    NSString* segueName = [module objectForKey:@"segue"];
    
    [self performSegueWithIdentifier:segueName sender:nil];
}

#pragma mark - private
- (void)reloadClassList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* classInfoList = [EntityClassInfoHelper updateEntities:responseObject
                                                           forEmployee:engine.loginInfo.uid
                                                        ofKindergarten:engine.loginInfo.schoolId.integerValue];
        [engine onLoadClassInfoList:classInfoList];
        
        [app hideAlert];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [app hideAlert];
        if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiUnauthorized
                                                                object:error
                                                              userInfo:nil];
        }
    };
    
    [app waitingAlert:@"获取信息" withTitle:@"请稍候"];
    [http opGetClassListOfKindergarten:engine.loginInfo.schoolId.integerValue
                        withEmployeeId:engine.loginInfo.phone
                               success:success
                               failure:failure];
}

- (void)reloadRelationships {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* relationships = [EntityRelationshipInfoHelper updateEntities:responseObject];
        [app hideAlert];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [app hideAlert];
    };
    
    [app waitingAlert:@"获取信息" withTitle:@"请稍候"];
    
    NSMutableArray* classIds = [NSMutableArray array];
    for (EntityClassInfo* entity in engine.classInfoList) {
        if (entity.classId) {
            [classIds addObject:entity.classId.stringValue];
        }
    }
    
    [http opGetRelationshipOfClasses:nil
                      inKindergarten:engine.loginInfo.schoolId.integerValue
                             success:success
                             failure:failure];
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
                               kTestChildId,
                               @((long long)[[NSDate date] timeIntervalSince1970]*1000)];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        _videoUrl = [NSString stringWithFormat:@"%@/%@", kQiniuDownloadServerHost, videoFileName];
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
                                 kTestChildId,
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
                             withSenderId:engine.loginInfo.uid
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

- (IBAction)onBtnSettingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.main.setting" sender:nil];
}

@end

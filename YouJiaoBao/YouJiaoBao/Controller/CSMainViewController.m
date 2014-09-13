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

#define kTestChildId    @"2_2088_900"

@interface CSMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray* _modules;
    
    NSMutableArray* _imageUrlList;
    NSMutableArray* _imageList;
    NSString* _textContent;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"header.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont: [UIFont systemFontOfSize:20], UITextAttributeTextColor:[UIColor whiteColor]}];
    
    _modules = @[@{@"icon": [UIImage imageNamed:@"notice.png"],
                   @"segue": @"segue.main.notice",
                   @"name": @"园内公告"},
                 
                 @{@"icon": [UIImage imageNamed:@"babylist.png"],
                   @"segue": @"segue.main.babylist",
                   @"name": @"宝宝列表"},
                 
                 @{@"icon": [UIImage imageNamed:@"growexp.png"],
                   @"segue": @"segue.main.growexp",
                   @"name": @"成长经历"},
                 
                 @{@"icon": [UIImage imageNamed:@"hw.png"],
                   @"segue": @"segue.main.hw",
                   @"name": @"亲子作业"},
                 
                 @{@"icon": [UIImage imageNamed:@"setting.png"],
                   @"segue": @"segue.main.setting",
                   @"name": @"设置"}
                 ];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self reloadClassList];
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
    if ([segue.identifier isEqualToString:@"segue.main.growexp"]) {
        CSContentEditorViewController* ctrl = segue.destinationViewController;
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

#pragma mark - CSContentEditorViewControllerDelegate
- (void)contentEditorViewController:(CSContentEditorViewController*)ctrl
                     finishEditText:(NSString*)text
                          withTitle:(NSString*)title
                         withImages:(NSArray*)imageList {
    _textContent = text;
    _imageUrlList = [NSMutableArray array];
    _imageList = [NSMutableArray arrayWithArray:imageList];
    
    if (_imageList.count > 0) {
        [self doUploadImage];
    }
    else {
        [self doSendHistory];
    }
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
    
    [gApp waitingAlert:@"提交数据中"];
    
    [http opPostHistoryOfKindergarten:engine.loginInfo.schoolId.integerValue
                         withSenderId:engine.loginInfo.uid
                          withChildId:kTestChildId
                          withContent:_textContent
                     withImageUrlList:_imageUrlList
                              success:sucessHandler
                              failure:failureHandler];
}

@end

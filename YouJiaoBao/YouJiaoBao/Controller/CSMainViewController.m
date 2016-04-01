//
//  CSMainViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSMainViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "CSAppDelegate.h"
#import "CSHttpUrls.h"
#import "CSModuleCell.h"
#import "CSStudentListPickUpTableViewController.h"
#import "CSContentEditorViewController.h"
#import "CBIMChatListViewController.h"
#import "CBSessionDataModel.h"

#define kTestChildId    @"2_2088_900"

@interface CSMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray* _modules;
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
                   @"segue": @"segue.main.growexpmain",
                   @"name": @"成长经历"},
                 @{@"icon": [UIImage imageNamed:@"v2-家园互动"],
                   @"segue": @"segue.main.im",
                   @"name": @"家园互动"},
                 ];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self reloadClassList];
    [self reloadRelationships];
    [self reloadIneligibleClass];
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
    
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    if (session.schoolInfo == nil) {
        [session reloadSchoolInfo];
    }
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
    NSString* moduleName = [module objectForKey:@"name"];
    if ([moduleName isEqualToString:@"家园互动"]) {
        [self openRCIM];
    }
    else {
        [self performSegueWithIdentifier:segueName sender:nil];
    }
}

#pragma mark - private
- (void)reloadClassList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [session updateClassInfosByJsonObject:responseObject];
        [engine onLoadClassInfoList:session.classInfoList];
        
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
    [http opGetClassListOfKindergarten:session.loginInfo.school_id.integerValue
                        withEmployeeId:session.loginInfo.phone
                               success:success
                               failure:failure];
}

- (void)reloadRelationships {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSAppDelegate* app = [CSAppDelegate sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [session updateRelationshipsByJsonObject:responseObject];
        [app hideAlert];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [app hideAlert];
    };
    
    [app waitingAlert:@"获取信息" withTitle:@"请稍候"];
    
    NSMutableArray* classIds = [NSMutableArray array];
    NSArray* classInfoList = session.classInfoList;
    for (CBClassInfo* classInfo in classInfoList) {
        [classIds addObject:[@(classInfo.class_id) stringValue]];
    }
    
    [http opGetRelationshipOfClasses:nil
                      inKindergarten:session.loginInfo.school_id.integerValue
                             success:success
                             failure:failure];
}

- (void)reloadIneligibleClass {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    //CSEngine* engine = [CSEngine sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    //CSAppDelegate* app = [CSAppDelegate sharedInstance];
    if (session.loginInfo) {
        [http reqGetiIneligibleClass:session.loginInfo.uid.integerValue
                      inKindergarten:session.loginInfo.school_id.integerValue
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if ([responseObject isKindOfClass:[NSArray class]]) {
                                     session.ineligibleClassList = responseObject;
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [self reloadIneligibleClass];
                                 });
                             }];
    }
}



- (IBAction)onBtnSettingsClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.main.setting" sender:nil];
}

- (void)openRCIM {
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    NSArray* arr1 = @[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)];
    if (session.schoolConfig.schoolGroupChat) {
        arr1 = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_GROUP),@(ConversationType_SYSTEM)];
    }
    
    NSArray* arr2 = nil;

    
    CBIMChatListViewController* ctrl = [[CBIMChatListViewController alloc] initWithDisplayConversationTypes:arr1
                                                                                 collectionConversationType:arr2];
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end

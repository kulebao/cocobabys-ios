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
#import "CSHttpUrls.h"
#import "CSModuleCell.h"
#import "CSStudentListPickUpTableViewController.h"
#import "CSContentEditorViewController.h"
#import "EntityClassInfo.h"
#import "EntityRelationshipInfoHelper.h"
#import "CBIMChatListViewController.h"

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
    
    CSEngine* engine = [CSEngine sharedInstance];
    if (engine.schoolInfo == nil) {
        [engine reloadSchoolInfo];
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
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* classInfoList = [EntityClassInfoHelper updateEntities:responseObject
                                                           forEmployee:engine.loginInfo.o_id
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

- (void)reloadIneligibleClass {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    //CSAppDelegate* app = [CSAppDelegate sharedInstance];
    if (engine.loginInfo) {
        [http reqGetiIneligibleClass:engine.loginInfo.uid.integerValue
                      inKindergarten:engine.loginInfo.schoolId.integerValue
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if ([responseObject isKindOfClass:[NSArray class]]) {
                                     engine.loginInfo.ineligibleClassList = responseObject;
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
    NSArray* arr1 = @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_GROUP),@(ConversationType_SYSTEM)];
    NSArray* arr2 = nil;
    CBIMChatListViewController* ctrl = [[CBIMChatListViewController alloc] initWithDisplayConversationTypes:arr1
                                                                                 collectionConversationType:arr2];
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end

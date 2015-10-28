//
//  CBCommercialMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 8/20/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBCommercialMainViewController.h"
#import "CBActivityMainViewController.h"
#import "CBContractorMainViewController.h"
#import "CBActivityDetailViewController.h"
#import "CBContractorDetailViewController.h"
#import "CSAppDelegate.h"

@interface CBCommercialMainViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segType;
@property (nonatomic, strong) CBActivityMainViewController* activityMainViewCtrl;
@property (nonatomic, strong) CBContractorMainViewController* contractorMainViewCtrl;
- (IBAction)onSegTypeValueChanged:(id)sender;

@end

@implementation CBCommercialMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeBackBarItem2];
    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"v2-head.png"] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.translucent = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onOpenActivity:)
                                                 name:@"noti.open.activity"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onOpenContractor:)
                                                 name:@"noti.open.contractor"
                                               object:nil];
    
    
    [self reloadViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[BaiduMobStat defaultStat] pageviewStartWithName:@"亲子优惠"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BaiduMobStat defaultStat] pageviewEndWithName:@"亲子优惠"];
}

- (CBActivityMainViewController*) activityMainViewCtrl {
    if (_activityMainViewCtrl == nil) {
        _activityMainViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CBActivityMainViewController"];
        [self addChildViewController:_activityMainViewCtrl];
        [self.view addSubview:_activityMainViewCtrl.view];
    }
    
    return _activityMainViewCtrl;
}

- (CBContractorMainViewController*) contractorMainViewCtrl {
    if (_contractorMainViewCtrl == nil) {
        _contractorMainViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CBContractorMainViewController"];
        [self addChildViewController:_contractorMainViewCtrl];
        [self.view addSubview:_contractorMainViewCtrl.view];
    }
    
    return _contractorMainViewCtrl;
}

- (IBAction)onSegTypeValueChanged:(id)sender {
    [self reloadViews];
}

- (void)reloadViews {
    if (self.segType.selectedSegmentIndex == 0) {
        [self.view bringSubviewToFront:self.activityMainViewCtrl.view];
        [self.activityMainViewCtrl reloadData];
    }
    else {
        [self.view bringSubviewToFront:self.contractorMainViewCtrl.view];
        [self.contractorMainViewCtrl reloadData];
    }
}

- (void)onOpenActivity:(NSNotification*)noti {
    [self performSegueWithIdentifier:@"segue.activity.detail" sender:noti.object];
}

- (void)onOpenContractor:(NSNotification*)noti {
    [self performSegueWithIdentifier:@"segue.contractor.detail" sender:noti.object];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.activity.detail"]) {
        CBActivityDetailViewController* ctrl = segue.destinationViewController;
        ctrl.itemData = sender;
    }
    else if ([segue.identifier isEqualToString:@"segue.contractor.detail"]) {
        CBContractorDetailViewController* ctrl = segue.destinationViewController;
        ctrl.itemData = sender;
    }
}

@end

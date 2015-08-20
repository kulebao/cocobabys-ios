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

@interface CBCommercialMainViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segType;
@property (nonatomic, strong) CBActivityMainViewController* activityMainViewCtrl;
@property (nonatomic, strong) CBContractorMainViewController* contractorMainViewCtrl;
- (IBAction)onSegTypeValueChanged:(id)sender;

@end

@implementation CBCommercialMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeBackBarItem];
    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"v2-head.png"] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    navigationBar.tintColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self addChildViewController:self.activityMainViewCtrl];
    [self addChildViewController:self.contractorMainViewCtrl];
    
    [self.view addSubview:self.activityMainViewCtrl.view];
    [self.view addSubview:self.contractorMainViewCtrl.view];
    
    [self reloadViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CBActivityMainViewController*) activityMainViewCtrl {
    if (_activityMainViewCtrl == nil) {
        _activityMainViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CBActivityMainViewController"];
    }
    
    return _activityMainViewCtrl;
}

- (CBContractorMainViewController*) contractorMainViewCtrl {
    if (_contractorMainViewCtrl == nil) {
        _contractorMainViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CBContractorMainViewController"];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

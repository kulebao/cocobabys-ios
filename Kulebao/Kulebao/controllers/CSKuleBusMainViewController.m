//
//  CSKuleBusMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/7/2.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleBusMainViewController.h"

@interface CSKuleBusMainViewController ()
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;

@end

@implementation CSKuleBusMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showMapScaleBar = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

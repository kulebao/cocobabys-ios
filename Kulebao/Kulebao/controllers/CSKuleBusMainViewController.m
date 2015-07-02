//
//  CSKuleBusMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/7/2.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleBusMainViewController.h"

@interface CSKuleBusMainViewController () {
    NSInteger _positionType; // 0 default, 1 user, 2 bus
}
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *labAddess;
@property (weak, nonatomic) IBOutlet UIButton *btnShowPosition;
@property (weak, nonatomic) IBOutlet UILabel *labDistance;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segMapMode;
- (IBAction)onSegMapModeValueChanged:(id)sender;
- (IBAction)onBtnShowPositionClicked:(id)sender;

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

- (IBAction)onSegMapModeValueChanged:(id)sender {
    if (self.segMapMode.selectedSegmentIndex == 0) {
        [self.mapView setMapType:BMKMapTypeStandard];
    }
    else {
        [self.mapView setMapType:BMKMapTypeSatellite];
    }
}

- (IBAction)onBtnShowPositionClicked:(id)sender {
    if (_positionType == 1) {
        [self.btnShowPosition setTitle:@"看校车的位置" forState:UIControlStateNormal];
        _positionType = 2;
    }
    else {
        [self.btnShowPosition setTitle:@"看自己的位置" forState:UIControlStateNormal];
        _positionType = 1;
    }
}

- (void)moveMapToUser {
    
}

- (void)moveMapToBus {
    
}

@end

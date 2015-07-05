//
//  CSKuleBusMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/7/2.
//  Copyright (c) 2015年 Cocobabys. All rights reserved.
//

#import "CSKuleBusMainViewController.h"
#import "CSAppDelegate.h"
#import "CSHttpClient.h"

enum {
    kMaxTimeCount = 15, //15s
};

typedef enum : NSUInteger {
    kBusStatusUnknown,
    kBusStatusNotFound,
    kBusStatusNormal,
} BusStatus;

typedef enum : NSUInteger {
    kViewportViewportTypeNone,
    kViewportViewportTypeUser,
    kViewportViewportTypeBus,
} ViewportType;

@interface CSKuleBusMainViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate> {
    NSInteger _viewportType; // 0 default, 1 user, 2 bus
    NSInteger _counter;
    NSInteger _busStatus;
    NSInteger _enteryTimers;
    
    BMKLocationService* _locService;
}

@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *labAddess;
@property (weak, nonatomic) IBOutlet UIButton *btnShowPosition;
@property (weak, nonatomic) IBOutlet UILabel *labDistance;
@property (weak, nonatomic) IBOutlet UILabel *labCountdown;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segMapMode;
@property (weak, nonatomic) IBOutlet UIStepper *stepperMapZoom;

@property (nonatomic, weak) NSTimer* refreshTimer;

- (IBAction)onSegMapModeValueChanged:(id)sender;
- (IBAction)onBtnShowPositionClicked:(id)sender;
- (IBAction)onStepperMapZoomValueChanged:(id)sender;

@end

@implementation CSKuleBusMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBackBarItem];

    //self.mapView.showsUserLocation = YES;
    //self.mapView.showMapScaleBar = YES;

    self.mapView.zoomLevel = 13;
    self.stepperMapZoom.value =  self.mapView.zoomLevel;
    self.stepperMapZoom.minimumValue =  self.mapView.minZoomLevel;
    self.stepperMapZoom.maximumValue =  self.mapView.maxZoomLevel;
    
    _counter = kMaxTimeCount;
    [self updateCountdownLabel];
    [self updateBusLocationLabel];
    [self doRefreshBusLocation];
    
    
    _locService = gApp.engine.locService;
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层

    [self showLocationFirstTimer:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.refreshTimer invalidate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
    
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    _locService.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(onTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
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
    switch (_viewportType) {
        case kViewportViewportTypeNone:
            _viewportType = kViewportViewportTypeUser;
            [self moveMapToUser];
            [self.btnShowPosition setTitle:@"看校车的位置" forState:UIControlStateNormal];
            break;
        case kViewportViewportTypeUser:
            _viewportType = kViewportViewportTypeBus;
            [self moveMapToBus];
            [self.btnShowPosition setTitle:@"看自己的位置" forState:UIControlStateNormal];
            break;
        case kViewportViewportTypeBus:
            _viewportType = kViewportViewportTypeUser;
            [self moveMapToUser];
            [self.btnShowPosition setTitle:@"看校车的位置" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (IBAction)onStepperMapZoomValueChanged:(id)sender {
    self.mapView.zoomLevel = self.stepperMapZoom.value;
}

- (void)moveMapToUser {
    _enteryTimers = 0;
    [self showLocationFirstTimer];
}

- (void)moveMapToBus {
    
}

- (void)doRefreshBusLocation {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {

    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:error.localizedDescription];
        
        if (operation.response.statusCode == 404) {
            _busStatus = kBusStatusNotFound;
            [self updateBusLocationLabel];
        }
    };
    
    //[gApp waitingAlert:@"获取数据中" withTitle:@"请稍候"];
    [gApp.engine reqGetBusLocationOfKindergarten:gApp.engine.loginInfo.schoolId
                                     withChildId:gApp.engine.currentRelationship.child.childId
                                         success:sucessHandler
                                         failure:failureHandler];
}

- (void)showLocationFirstTimer {
    [self showLocationFirstTimer:YES];
}

- (void)showLocationFirstTimer:(BOOL)animated{
    if (_enteryTimers == 0
        && _locService.userLocation.location) {
        _enteryTimers++;
        [self.mapView setCenterCoordinate:_locService.userLocation.location.coordinate
                                 animated:animated];
    }
}

#pragma mark - Timer
- (void)onTimer:(NSTimer*)sender {
    --_counter;
    
    if (_counter <= 0) {
        _counter = kMaxTimeCount;
        [self performSelector:@selector(doRefreshBusLocation) withObject:nil afterDelay:0.1];
    }
    
    [self updateCountdownLabel];
}

- (void)updateCountdownLabel {
    self.labCountdown.text = [NSString stringWithFormat:@"%ld秒后刷新", _counter];
}

- (void)updateBusLocationLabel {
    self.labAddess.text = @"校车还未出发";
    
    if (_busStatus == kBusStatusUnknown) {
        self.labAddess.text = @"校车还未出发";
    }
    else if (_busStatus == kBusStatusNotFound) {
        self.labAddess.text = @"校车还未出发";
    }
    else {
        self.labAddess.text = @"校车位置: xxx";
    }
}

#pragma mark - Delegates
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser {
    CSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
    //CSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    //    CSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    [self showLocationFirstTimer];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser {
    CSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    CSLog(@"location error");
}


@end

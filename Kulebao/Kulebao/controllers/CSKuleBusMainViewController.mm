//
//  CSKuleBusMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/7/2.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
//

#import "CSKuleBusMainViewController.h"
#import "CSAppDelegate.h"
#import "CSKuleInterpreter.h"

enum {
    kMaxTimeCount = 15, //15s
};

typedef enum : NSUInteger {
    kBusStatusUnknown,
    kBusStatusNotFound,
    kBusStatusNormal,
    kBusStatusOff,
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

@property (nonatomic, strong) CSKuleBusLocationInfo* busLocationInfo;
@property (nonatomic, strong) BMKPointAnnotation* busAnnotation;

@property (nonatomic, weak) NSTimer* refreshTimer;

- (IBAction)onSegMapModeValueChanged:(id)sender;
- (IBAction)onBtnShowPositionClicked:(id)sender;
- (IBAction)onStepperMapZoomValueChanged:(id)sender;

@end

@implementation CSKuleBusMainViewController
@synthesize busLocationInfo = _busLocationInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    //self.mapView.showsUserLocation = YES;
    self.mapView.showMapScaleBar = YES;
    self.mapView.zoomLevel = 16;
    self.stepperMapZoom.value =  self.mapView.zoomLevel;
    self.stepperMapZoom.minimumValue =  self.mapView.minZoomLevel;
    self.stepperMapZoom.maximumValue =  self.mapView.maxZoomLevel;
    
    _viewportType = kViewportViewportTypeBus;
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
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
            [self moveMapToUser];
            if (self.busLocationInfo) {
                _viewportType = kViewportViewportTypeUser;
                [self.btnShowPosition setTitle:@"看校车的位置" forState:UIControlStateNormal];
            }
            break;
        default:
            break;
    }
}

- (IBAction)onStepperMapZoomValueChanged:(id)sender {
    self.mapView.zoomLevel = self.stepperMapZoom.value;
}

- (void)moveMapToUser {
    if (_locService.userLocation.location) {
        [self.mapView setCenterCoordinate:_locService.userLocation.location.coordinate
                                 animated:YES];
    }
}

- (void)moveMapToBus {
    if (_busLocationInfo) {
        //[self.mapView addAnnotation:self.busAnnotation];
        [self.mapView setCenterCoordinate:self.busAnnotation.coordinate animated:YES];
    }
    else {
        //[self.mapView removeAnnotation:self.busAnnotation];
    }
}

- (void)doRefreshBusLocation {
    SuccessResponseHandler sucessHandler = ^(NSURLSessionDataTask *task, id dataJson) {
        _busStatus = kBusStatusNormal;
        self.busLocationInfo = [CSKuleInterpreter decodeBusLocation:dataJson];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLSessionDataTask *task, NSError *error) {
        CSLog(@"failure:%@", error);
        //[gApp alert:error.localizedDescription];
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        if (response.statusCode == 404) {
            NSError* err = nil;
            NSData* responseData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
            id dataJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
            
            if (dataJson) {
                /*
                 1表示未出发
                 2表示上午下车NSURLSessionDownloadDelegate
                 4表示下午下车
                 */
                NSInteger error_code = [[dataJson objectForKey:@"error_code"] integerValue];
                NSString* error_msg = [dataJson objectForKey:@"error_msg"];
                
                if (error_code == 1) {
                    _busStatus = kBusStatusNotFound;
                }
                else if (error_code == 2 || error_code == 4) {
                    _busStatus = kBusStatusOff;
                }
                else {
                    _busStatus = kBusStatusUnknown;
                }
                
            }
            else {
                _busStatus = kBusStatusNotFound;
            }
            
            [self updateBusLocationLabel];
        }
    };
    
    //[gApp waitingAlert:@"获取数据中" withTitle:@"请稍候"];
    [gApp.engine.httpClient reqGetBusLocationOfKindergarten:gApp.engine.loginInfo.schoolId
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

    [self updateDisLabel];
}

- (void)setBusLocationInfo:(CSKuleBusLocationInfo *)busLocationInfo {
    _busLocationInfo = busLocationInfo;
    [self.mapView removeAnnotation:self.busAnnotation];
    
    if (_busLocationInfo) {
        if (_busStatus == kBusStatusNormal) {
            CLLocationCoordinate2D coor;
            coor.longitude = _busLocationInfo.longitude;
            coor.latitude = _busLocationInfo.latitude;
            self.busAnnotation.coordinate = coor;
            [self.mapView addAnnotation:self.busAnnotation];
        }
        
        [self updateBusLocationLabel];
    }
    
    [self updateDisLabel];
    
    if (_viewportType == kViewportViewportTypeBus) {
        [self moveMapToBus];
    }
}

- (BMKPointAnnotation*)busAnnotation {
    if (_busAnnotation == nil) {
        _busAnnotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        _busAnnotation.coordinate = coor;
        _busAnnotation.title = @"校车";
        _busAnnotation.subtitle = nil;
        
        [_mapView addAnnotation:_busAnnotation];
    }
    
    return _busAnnotation;
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
    if (_busStatus == kBusStatusUnknown) {
        self.labAddess.text = @"校车还未出发";
    }
    else if (_busStatus == kBusStatusNotFound) {
        self.labAddess.text = @"校车还未出发";
    }
    else if (_busStatus == kBusStatusOff) {
        self.labAddess.text = @"小孩已下车";
    }
    else if (_busLocationInfo) {
        if (_busLocationInfo.address.length > 0) {
            self.labAddess.text = [NSString stringWithFormat:@"校车位置: %@", _busLocationInfo.address];
        }
        else {
            // DO NOTHING
        }
    }
    else {
        self.labAddess.text = @"获取位置中";
    }
}

- (void)updateDisLabel {
    if (_locService.userLocation.location
        && _busLocationInfo) {
        CLLocationCoordinate2D busCoor;
        busCoor.latitude = _busLocationInfo.latitude;
        busCoor.longitude = _busLocationInfo.longitude;
        BMKMapPoint userPoint = BMKMapPointForCoordinate(_locService.userLocation.location.coordinate);
        BMKMapPoint busPoint = BMKMapPointForCoordinate(busCoor);
        CLLocationDistance dis = BMKMetersBetweenMapPoints(userPoint, busPoint);
        self.labDistance.text = [NSString stringWithFormat:@"相距%ld米", (NSInteger)dis];
    }
    else {
        self.labDistance.text = nil;
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

#pragma mark implement BMKMapViewDelegate
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {

    //普通annotation
    if (annotation == _busAnnotation) {
        NSString *AnnotationViewID = @"renameMark";
        BMKAnnotationView *annotationView = (BMKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            // 设置颜色
            //BMKAnnotationViewannotationView.pinColor = BMKPinAnnotationColorPurple;
            // 从天上掉下效果
            //annotationView.animatesDrop = NO;
            // 设置可拖拽
            //annotationView.draggable = YES;
            annotationView.image = [UIImage imageNamed:@"v2-bus-pin.png"];
        }
        return annotationView;
    }
    
    return nil;
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    CSLog(@"paopaoclick");
}

@end

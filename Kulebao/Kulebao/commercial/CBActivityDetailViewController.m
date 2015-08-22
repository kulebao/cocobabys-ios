//
//  CBActivityDetailViewController.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015 Cocobabys. All rights reserved.
//

#import "CBActivityDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "CSAppDelegate.h"
#import "CSHttpClient.h"
#import <MapKit/MapKit.h>

@interface CBActivityDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labPrice;
@property (weak, nonatomic) IBOutlet UILabel *labPhone;
@property (weak, nonatomic) IBOutlet UILabel *labAddress;
@property (weak, nonatomic) IBOutlet UITextView *textDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnJoin;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;

- (IBAction)onBtnCallClicked:(id)sender;
- (IBAction)onBtnNaviClicked:(id)sender;
- (IBAction)onBtnJoinClicked:(id)sender;

@end

@implementation CBActivityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.imgIcon addGestureRecognizer:self.tapGes];
    self.imgIcon.userInteractionEnabled = YES;
    
    [self.btnJoin setBackgroundImage:[[UIImage imageNamed:@"v2-btn_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]
                            forState:UIControlStateDisabled];
    
    [self reloadData];
    
    if(!self.itemData.joined) {
        [self queryJoinStatus];
    }
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

- (void)setItemData:(CBActivityData *)activityData {
    _itemData = activityData;
    
    if ([self isViewLoaded]) {
        [self reloadData];
    }
}

- (void)reloadData {
    CBLogoData* logo = self.itemData.logos.firstObject;
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"v2-logo2.png"]];
    self.labTitle.text = self.itemData.title;
    
    NSString* discounted = self.itemData.price.discounted;
    NSString* origin = self.itemData.price.origin;
    if (discounted.length == 0) {
        discounted = @"0";
    }
    if (origin.length == 0) {
        origin = @"0";
    }
    self.labPrice.text = [NSString stringWithFormat:@"%@ %@", discounted, origin];
    self.labPhone.text = self.itemData.contact;
    self.labAddress.text = self.itemData.address;
    self.textDetail.text = self.itemData.detail;
    
    [self updateJoinStatus];
}

- (IBAction)onBtnCallClicked:(id)sender {
    BOOL ok = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.itemData.contact]]];
    if (!ok && self.itemData.contact.length > 0) {
        [gApp alert:@"本设备不支持拨打电话"];
    }
}

- (IBAction)onBtnNaviClicked:(id)sender {
    if (self.itemData.location) {
        //当前的位置
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];

        //目的地的位置
        CLLocationCoordinate2D coord = {self.itemData.location.latitude, self.itemData.location.longitude};
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coord
                                                                                           addressDictionary:nil]];
        toLocation.name = self.itemData.location.address;
        NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
        
        /*
         //keys
         MKLaunchOptionsMapCenterKey:地图中心的坐标(NSValue)
         MKLaunchOptionsMapSpanKey:地图显示的范围(NSValue)
         MKLaunchOptionsShowsTrafficKey:是否显示交通信息(boolean NSNumber)
         
         //MKLaunchOptionsDirectionsModeKey: 导航类型(NSString)
         {
         MKLaunchOptionsDirectionsModeDriving:驾车
         MKLaunchOptionsDirectionsModeWalking:步行
         }
         
         //MKLaunchOptionsMapTypeKey:地图类型(NSNumber)
         enum {
         MKMapTypeStandard = 0,
         MKMapTypeSatellite,
         MKMapTypeHybrid
         };
         */
        NSDictionary *options = @{
                                  MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                  MKLaunchOptionsMapTypeKey:
                                      [NSNumber numberWithInteger:MKMapTypeStandard],
                                  MKLaunchOptionsShowsTrafficKey:@YES  
                                  };  
        //打开苹果自身地图应用，并呈现特定的item  
        [MKMapItem openMapsWithItems:items launchOptions:options];
    }
    else {
        [gApp alert:@"商户位置未提供，导航失败"];
    }
}

- (IBAction)onBtnJoinClicked:(id)sender {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        self.itemData.joined = YES;
        [gApp alert:@"报名成功"];
        
        [self updateJoinStatus];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError* err = nil;
        NSString* error_msg = nil;
        id dataJson = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&err];
        if (dataJson && !err) {
            // {"error_msg":"不能重复报名同一活动。(duplicated enrollment)","error_code":3}
            error_msg = dataJson[@"error_msg"];
        }
        if (error_msg) {
            [gApp alert:error_msg];
        }
        else {
            [gApp alert:[error localizedDescription]];
        }
    };
    
    [gApp waitingAlert:@"报名中，请稍候..."];
    [gApp.engine reqPostEnrollmentOfKindergarten:gApp.engine.loginInfo.schoolId
                                    withActivity:self.itemData
                                         success:sucessHandler
                                         failure:failureHandler];
}

- (void)updateJoinStatus {
    self.btnJoin.enabled = !self.itemData.joined;
}

- (void)queryJoinStatus {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        self.itemData.joined = YES;
        [self updateJoinStatus];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError* err = nil;
        NSString* error_msg = nil;
        id dataJson = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&err];
        if (dataJson && !err) {
            // {"error_msg":"不能重复报名同一活动。(duplicated enrollment)","error_code":3}
            error_msg = dataJson[@"error_msg"];
        }
        if (error_msg) {
            //[gApp alert:error_msg];
        }
        else {
            //[gApp alert:[error localizedDescription]];
        }
    };
    
    [gApp.engine reqGetEnrollmentOfKindergarten:gApp.engine.loginInfo.schoolId
                                   withActivity:self.itemData.uid
                                        success:sucessHandler
                                        failure:failureHandler];
}

- (void)onTap:(UITapGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        UIImageView* imgView = self.imgIcon;
        
        if (imgView && _itemData.logos.count>0) {
            MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
            
            NSMutableArray* photoList = [NSMutableArray array];
            for (CBLogoData* logoData in _itemData.logos) {
                MJPhoto* photo = [MJPhoto new];
                photo.srcImageView = nil;
                photo.url = [NSURL URLWithString:logoData.url];
                [photoList addObject:photo];
            }
            
            browser.photos = photoList;
            browser.currentPhotoIndex = 0;
            
            [browser show];
        }
    }
}

@end

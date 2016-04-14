//
//  CBContractorDetailViewController.m
//  youlebao
//
//  Created by xin.c.wang on 8/21/15.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
//

#import "CBContractorDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "CSAppDelegate.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <MapKit/MapKit.h>
#import "CBActivityData.h"
#import "CBActivityDetailViewController.h"

@interface CBContractorDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labMorePics;

@property (nonatomic, strong) UITapGestureRecognizer* tapGes;
@property (nonatomic, strong) NSMutableArray* cellItemDataList;

@end

@implementation CBContractorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.imgIcon addGestureRecognizer:self.tapGes];
    self.imgIcon.userInteractionEnabled = YES;
    self.labMorePics.text = nil;
    
    self.tableInfo.delegate = self;
    self.tableInfo.dataSource = self;
    self.tableInfo.estimatedRowHeight = 44;
    self.tableInfo.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    _cellItemDataList = [NSMutableArray array];
    
    [self reloadData];
    [self reloadCellItemDataList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[BaiduMobStat defaultStat] pageviewStartWithName:@"亲子优惠商户详情"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BaiduMobStat defaultStat] pageviewEndWithName:@"亲子优惠商户详情"];
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
}

- (void)setItemData:(CBContractorData *)itemData{
    _itemData = itemData;
    
    if ([self isViewLoaded]) {
        [self reloadData];
    }
}

- (void)reloadData {
    CBLogoData* logo = _itemData.logos.firstObject;
    [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"v2-logo2.png"]];
    self.labTitle.text = _itemData.title;
    if (logo) {
        self.labMorePics.text = [NSString stringWithFormat:@"%ld张 >>", _itemData.logos.count];
    }
    else {
        self.labMorePics.text = nil;
    }
    
    [self.tableInfo reloadData];
}

- (void)openCall {
    BOOL ok = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.itemData.contact]]];
    if (!ok && self.itemData.contact.length > 0) {
        [gApp alert:@"拨打电话失败"];
    }
}

- (void)openMap {
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

- (void)onTap:(UITapGestureRecognizer*)ges {
    if (ges.state == UIGestureRecognizerStateEnded) {
        UIImageView* imgView = self.imgIcon;
        
        if (imgView && _itemData.logos.count>0) {
            MJPhotoBrowser* browser = [[MJPhotoBrowser alloc] init];
            
            NSMutableArray* photoList = [NSMutableArray array];
            for (CBLogoData* logoData in _itemData.logos) {
                MJPhoto* photo = [MJPhoto new];
                photo.srcImageView = self.imgIcon;
                photo.url = [NSURL URLWithString:logoData.url];
                [photoList addObject:photo];
            }
            
            browser.photos = photoList;
            browser.currentPhotoIndex = 0;
            browser.hidenToolbar = NO;
            browser.hidenSaveBtn = YES;
            
            [browser show];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 2;
    }
    else if (section == 1) {
        numberOfRows = self.cellItemDataList.count;
    }
    else if (section == 2) {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CBContractorDetailCell1"];
        UILabel* labTitle = (UILabel*)[cell.contentView viewWithTag:100];
        UILabel* labDetail = (UILabel*)[cell.contentView viewWithTag:101];
        if(row == 0) {
            labTitle.text = _itemData.contact;
            labDetail.text = @"电话咨询";
        }
        else {
            labTitle.text = _itemData.address;
            labDetail.text = @"查看位置";
        }
    }
    else if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CBContractorDetailCell2"];
        CBActivityData* itemData = [self.cellItemDataList objectAtIndex:row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configCell:cell withCellData:itemData];
    }
    else if (section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CBContractorDetailCell3"];
        UILabel* labDetail = (UILabel*)[cell.contentView viewWithTag:100];
        labDetail.text = _itemData.detail;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CBContractorDetailCell4"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CBContractorDetailCell4"];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0) {
        height = [tableView fd_heightForCellWithIdentifier:@"CBContractorDetailCell1"
                                          cacheByIndexPath:indexPath
                                             configuration:^(UITableViewCell* cell) {
                                                 UILabel* labTitle = (UILabel*)[cell.contentView viewWithTag:100];
                                                 UILabel* labDetail = (UILabel*)[cell.contentView viewWithTag:101];
                                                 if(row == 0) {
                                                     labTitle.text = _itemData.contact;
                                                     labDetail.text = @"电话咨询";
                                                 }
                                                 else {
                                                     labTitle.text = _itemData.address;
                                                     labDetail.text = @"查看位置";
                                                 }
                                             }];
        
        height = height < 44 ? 44 : height;
    }
    else if (section == 1) {
        height = 64;
    }
    else if (section == 2) {
        height = [tableView fd_heightForCellWithIdentifier:@"CBContractorDetailCell3"
                                          cacheByIndexPath:indexPath
                                             configuration:^(UITableViewCell* cell) {
                                                 UILabel* labDetail = (UILabel*)[cell.contentView viewWithTag:100];
                                                 labDetail.text = _itemData.detail;
                                             }];
        
        height = height < 64 ? 64 : height;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0) {
        if(row == 0) {
            [self openCall];
        }
        else {
            [self openMap];
        }
    }
    else if (section == 1) {
        CBActivityData* itemData = [self.cellItemDataList objectAtIndex:row];
        [self performSegueWithIdentifier:@"segue.activity.detail" sender:itemData];
    }
}

#pragma mark - LoadActivityList
- (void)reloadCellItemDataList {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [_cellItemDataList removeAllObjects];
        
        for (NSDictionary* json in dataJson) {
            CBActivityData* itemData = [CBActivityData instanceWithDictionary:json];
            if (itemData) {
                [_cellItemDataList addObject:itemData];
            }
        }
        
        [self.tableInfo reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [self.tableInfo reloadData];
    };
    
    [gApp.engine.httpClient reqGetActivityListOfKindergarten:gApp.engine.loginInfo.schoolId
                                 withContractorId:self.itemData.uid
                                             from:-1
                                               to:-1
                                             most:-1
                                          success:sucessHandler
                                          failure:failureHandler];
}

#pragma mark - Configure
- (void)configCell:(UITableViewCell*)cell withCellData:(CBActivityData*)itemData {

    NSString* discounted = itemData.price.discounted;
    NSString* origin = itemData.price.origin;
    if (discounted.length == 0) {
        discounted = @"0";
    }
    if (origin.length == 0) {
        origin = @"0";
    }
    
    origin = [NSString stringWithFormat:@"原价%@元", origin];
    
    NSMutableAttributedString* attriOrigin = [[NSMutableAttributedString alloc] initWithString:origin];
    [attriOrigin addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, origin.length)];
    [attriOrigin addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, origin.length)];
    [attriOrigin addAttribute:NSStrikethroughStyleAttributeName
                        value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)
                        range:NSMakeRange(0, origin.length)];
    
    discounted = [NSString stringWithFormat:@"幼乐宝用户专享 %@元 ", discounted];
    NSMutableAttributedString* attriDiscounted = [[NSMutableAttributedString alloc] initWithString:discounted];
    [attriDiscounted addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 7)];
    [attriDiscounted addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 7)];
    [attriDiscounted addAttribute:NSForegroundColorAttributeName value:UIColorRGB(0, 164, 217) range:NSMakeRange(7, discounted.length - 7)];
    [attriDiscounted addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(7, discounted.length - 7)];
    
    [attriDiscounted appendAttributedString:attriOrigin];
    
    UIImageView* imgLogo = (UIImageView*)[cell.contentView viewWithTag:100];
    UILabel* labTitle = (UILabel*)[cell.contentView viewWithTag:101];
    UILabel* labDetail = (UILabel*)[cell.contentView viewWithTag:102];
    
    CBLogoData* logo = itemData.logos.firstObject;
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:logo.url] placeholderImage:[UIImage imageNamed:@"v2-logo2.png"]];
    labTitle.text = itemData.title;
    labDetail.attributedText = attriDiscounted;
}

@end

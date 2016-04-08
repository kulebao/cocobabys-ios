//
//  CSKuleCheckinViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCheckinViewController.h"
#import "CSKuleCheckinLogListViewController.h"
#import "VRGCalendarView.h"
#import "NSDate+convenience.h"
#import "CSAppDelegate.h"
#import "NSDate+CSKit.h"
#import "CSTipsInfo.h"

@interface CSKuleCheckinViewController () <VRGCalendarViewDelegate>

@property (nonatomic, strong) UILabel* labCheckIn;
@property (nonatomic, strong) UILabel* labCheckOut;

@property (nonatomic, strong) NSMutableArray* checkInOutLogInfos;
@property (nonatomic, strong) VRGCalendarView* calendarView;

@property (nonatomic, strong) NSMutableArray* checkInDates;
@property (nonatomic, strong) NSMutableArray* checkOutDates;

@end

@implementation CSKuleCheckinViewController
@synthesize labCheckIn = _labCheckIn;
@synthesize labCheckOut = _labCheckOut;
@synthesize checkInOutLogInfos = _checkInOutLogInfos;
@synthesize calendarView = _calendarView;
@synthesize checkInDates = _checkInDates;
@synthesize checkOutDates = _checkOutDates;

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
    
    
    _calendarView = [[VRGCalendarView alloc] init];
    _calendarView.delegate=self;
    [self.view addSubview:_calendarView];
    
    self.labCheckIn = [[UILabel alloc] initWithFrame:CGRectNull];
    self.labCheckIn.backgroundColor = [UIColor clearColor];
    self.labCheckIn.font = [UIFont systemFontOfSize:13.0];
    self.labCheckIn.numberOfLines = 1;
    [self.view addSubview:self.labCheckIn];
    
    self.labCheckOut = [[UILabel alloc] initWithFrame:CGRectNull];
    self.labCheckOut.backgroundColor = [UIColor clearColor];
    self.labCheckOut.font = [UIFont systemFontOfSize:13.0];
    self.labCheckOut.numberOfLines = 1;
    [self.view addSubview:self.labCheckOut];
    
    CGFloat xx = 0;
    CGFloat yy = CGRectGetMaxY(_calendarView.frame);
    
    yy += 2;
    self.labCheckIn.frame = CGRectMake(xx, yy, self.view.bounds.size.width, 25);
    
    yy += 25;
    self.labCheckOut.frame = CGRectMake(xx, yy, self.view.bounds.size.width, 25);
    
    [gApp.engine addObserver:self
                  forKeyPath:@"badgeOfCheckin"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [gApp.engine removeObserver:self forKeyPath:@"badgeOfCheckin"];
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CSLog(@"%@ changed.", keyPath);
    if((object == gApp.engine) && [keyPath isEqualToString:@"badgeOfCheckin"]) {
        if (gApp.engine.badgeOfCheckin > 0) {
            [self reloadCheckInOutLogs];
        }
        else {
        }
    }
    else {
        CSLog(@"UNKNOWN.");
    }
}

#pragma mark - Private
- (void)reloadCheckInOutLogs {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* checkInOutLogInfos = [NSMutableArray array];
        
        CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
        NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleCheckin forChild:currentChild.childId];
        NSTimeInterval timestamp = oldTimestamp;
        
        for (id checkInOutLogInfoJson in dataJson) {
            CSKuleCheckInOutLogInfo* checkInOutLogInfo = [CSKuleInterpreter decodeCheckInOutLogInfo:checkInOutLogInfoJson];
            [checkInOutLogInfos addObject:checkInOutLogInfo];
            if (timestamp < checkInOutLogInfo.timestamp) {
                timestamp = checkInOutLogInfo.timestamp;
            }
        }
        
        if (oldTimestamp < timestamp) {
            [gApp.engine.preferences setTimestamp:timestamp
                                         ofModule:kKuleModuleCheckin
                                         forChild:currentChild.childId];
        }
        
        self.checkInOutLogInfos = checkInOutLogInfos;
        [self doUpdate];
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    NSDate* beginning = [_calendarView.currentMonth beginningOfMonth];
    NSDate* end = [beginning dateafterMonth:1];
    
    //CSLog(@"beginning=%@, end=%@", [beginning isoDateTimeString], [end isoDateTimeString]);
    
    NSTimeInterval beginTimestamp = [beginning timeIntervalSince1970];
    NSTimeInterval endTimestamp = [end timeIntervalSince1970];
    
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        [gApp waitingAlert:@"正在获取签到信息..."];
        [gApp.engine.httpClient reqGetCheckInOutLogOfChild:currentChild
                                 inKindergarten:gApp.engine.loginInfo.schoolId
                                           from:beginTimestamp
                                             to:endTimestamp
                                           most:999
                                        success:sucessHandler
                                        failure:failureHandler];
    }
    else {
        [gApp alert:@"没有宝宝信息。"];
    }
}

- (void)doUpdate{
    CSTipsInfo* tipsList[31] = {0};
    
    NSArray* sortedArray = [_checkInOutLogInfos sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(CSKuleCheckInOutLogInfo* obj1, CSKuleCheckInOutLogInfo* obj2) {
        
        NSComparisonResult result = NSOrderedSame;
        if (obj1.timestamp < obj2.timestamp) {
            result = NSOrderedAscending;
        }
        else if (obj1.timestamp > obj2.timestamp) {
            result = NSOrderedDescending;
        }
        
        return result;
    }];
    
    for (CSKuleCheckInOutLogInfo* checkInOutLogInfo in sortedArray) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp];
        NSUInteger day = [date getDay]-1;
        if (day < 31) {
            CSTipsInfo* tips = tipsList[day];
            if (tips == 0) {
                tips = [CSTipsInfo new];
                tipsList[day] = tips;
            }
            
            if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckIn) {
                tips.tips1 = [NSDate stringFromDate:date withFormat:@"HH:mm"];
                tips.tips2 = nil;
            }
            else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut) {
                tips.tips2 = [NSDate stringFromDate:date withFormat:@"HH:mm"];
            }
            else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckInCarMorning
                || checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOutCarMorning) {
                tips.tips3 = [NSDate stringFromDate:date withFormat:@"HH:mm"];
                tips.tips4 = nil;
            }
            else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut
                     || checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOutCarAfternoon) {
                tips.tips4 = [NSDate stringFromDate:date withFormat:@"HH:mm"];
            }
            else {
                CSLog(@"Unknown checkInOutLog: %@", checkInOutLogInfo);
            }
        }
        else {
            CSLog(@"date %d get day error.", day);
        }
    }
    
    NSMutableArray* dates = [NSMutableArray array];
    NSMutableArray* tipInfos = [NSMutableArray array];
    
    for (NSInteger i=0; i<31; i++) {
        CSTipsInfo* tips = tipsList[i];
        if (tips && (tips.tips1 || tips.tips2 || tips.tips3 || tips.tips4)) { // 不排除校车的显示
            [dates addObject:@(i+1)];
            [tipInfos addObject:tips];
            
            if (!tips.tips1) {
                tips.tips1 = @"未签到";
            }
            
            if (!tips.tips2) {
                tips.tips2 = @"未签退";
            }
            
            if (!tips.tips3) {
                tips.tips3 = @"未上车";
            }
            
            if (!tips.tips4) {
                tips.tips4 = @"未下车";
            }
        }
    }
    
    [_calendarView markDates:dates withTips:tipInfos];
    
    if ([_calendarView.currentMonth  getMonth] == [[NSDate date] getMonth]) {
        NSInteger curday = [[NSDate date] getDay]-1;
        if (curday < 31) {
            CSTipsInfo* tips = tipsList[curday];
            if (tips) {
                _labCheckIn.text = [NSString stringWithFormat:@"签到入园时间: %@", tips.tips1];
                _labCheckOut.text = [NSString stringWithFormat:@"签退离园时间: %@", tips.tips2];
            }
            else {
                _labCheckIn.text = @"今天没有刷卡记录";
                _labCheckOut.text = nil;
            }
        }
        else {
            CSLog(@"curday=%d error.", curday);
        }
    }
    else {
        _labCheckIn.text = nil;
        _labCheckOut.text = nil;
    }
}

#pragma mark - VRGCalendarViewDelegate
-(void)calendarView:(VRGCalendarView *)calendarView
    switchedToMonth:(int)month
       targetHeight:(float)targetHeight
           animated:(BOOL)animated {
    // 获取签到数据
    [self reloadCheckInOutLogs];
    
    NSTimeInterval animationInterval = animated ? 0.35 : 0;
    
    [UIView animateWithDuration:animationInterval animations:^{
        CGFloat xx = 0;
        CGFloat yy = targetHeight;
        
        yy += 2;
        self.labCheckIn.frame = CGRectMake(xx, yy, self.view.bounds.size.width, 25);
        
        yy += 25;
        self.labCheckOut.frame = CGRectMake(xx, yy, self.view.bounds.size.width, 25);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {
    NSUInteger selectedDay = [date getDay];
    NSMutableArray* selectedInfos = [NSMutableArray array];
    for (CSKuleCheckInOutLogInfo* checkInOutLogInfo in _checkInOutLogInfos) {
        NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp];
        NSUInteger day = [timestamp getDay];
        if (day == selectedDay) {
            [selectedInfos addObject:checkInOutLogInfo];
        }
    }
    
    //CSLog(@"selectedInfos.count = %d", selectedInfos.count);
    if (selectedInfos.count > 0) {
        [self performSegueWithIdentifier:@"segue.checkinLogList" sender:selectedInfos];
    }
    else {
    }
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.checkinLogList"]) {
        CSKuleCheckinLogListViewController* destCtrl = segue.destinationViewController;
        destCtrl.checkInOutLogInfoList = sender;
    }
}


@end

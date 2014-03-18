//
//  CSKuleCheckinViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCheckinViewController.h"
#import "VRGCalendarView.h"
#import "NSDate+convenience.h"
#import "CSAppDelegate.h"
#import "NSDate+CSKit.h"

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
    [self customizeBackBarItem];
    
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
    
    // 获取签到数据
    [self reloadCheckInOutLogs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)reloadCheckInOutLogs {
    SuccessResponseHandler sucessHandler = ^(NSURLRequest *request, id dataJson) {
        NSMutableArray* checkInOutLogInfos = [NSMutableArray array];
        
        for (id checkInOutLogInfoJson in dataJson) {
            CSKuleCheckInOutLogInfo* checkInOutLogInfo = [CSKuleInterpreter decodeCheckInOutLogInfo:checkInOutLogInfoJson];
            [checkInOutLogInfos addObject:checkInOutLogInfo];
        }
        
        self.checkInOutLogInfos = checkInOutLogInfos;
        [self doUpdate];
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(NSURLRequest *request, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    [gApp.engine reqGetCheckInOutLogOfChild:currentChild
                             inKindergarten:gApp.engine.loginInfo.schoolId
                                     from:-1
                                       to:-1
                                     most:-1
                                  success:sucessHandler
                                  failure:failureHandler];
}

- (void)doUpdate{
    _checkInDates = [[NSMutableArray alloc] initWithCapacity:_checkInOutLogInfos.count];
    _checkOutDates = [[NSMutableArray alloc] initWithCapacity:_checkInOutLogInfos.count];
    for (CSKuleCheckInOutLogInfo* checkInOutLogInfo in _checkInOutLogInfos) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp];
        if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckIn) {
            [_checkInDates addObject:date];
        }
        else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut) {
            [_checkOutDates addObject:date];
        }
        else {
            CSLog(@"Unknown checkInOutLog: %@", checkInOutLogInfo);
        }
    }
    
    NSMutableArray* dates = [NSMutableArray array];
    for (NSDate* d in _checkOutDates) {
        if ([d month] == [_calendarView.currentMonth month]) {
            [dates addObject:@([d day])];
        }
    }
    [_calendarView markDates:_checkOutDates];
}

#pragma mark - VRGCalendarViewDelegate
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
//    if (month==[[NSDate date] month]) {
//        NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:5], nil];
//        [calendarView markDates:dates];
//    }
    
    NSMutableArray* dates = [NSMutableArray array];
    for (NSDate* d in _checkOutDates) {
        if ([d month] == month) {
            [dates addObject:@([d day])];
        }
    }
    [calendarView markDates:dates];

    //[calendarView markDates:_checkOutDates];
    
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
    self.labCheckIn.text = [date string];
    self.labCheckOut.text = [date string];
}

@end

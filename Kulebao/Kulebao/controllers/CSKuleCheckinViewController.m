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

@interface CSKuleCheckinViewController () <VRGCalendarViewDelegate>

@property (nonatomic, strong) UILabel* labCheckIn;
@property (nonatomic, strong) UILabel* labCheckOut;

@end

@implementation CSKuleCheckinViewController
@synthesize labCheckIn = _labCheckIn;
@synthesize labCheckOut = _labCheckOut;

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
    
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate=self;
    [self.view addSubview:calendar];
    
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
    CGFloat yy = CGRectGetMaxY(calendar.frame);
    
    yy += 2;
    self.labCheckIn.frame = CGRectMake(xx, yy, self.view.bounds.size.width, 25);
    
    yy += 25;
    self.labCheckOut.frame = CGRectMake(xx, yy, self.view.bounds.size.width, 25);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VRGCalendarViewDelegate
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    if (month==[[NSDate date] month]) {
        NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:5], nil];
        [calendarView markDates:dates];
    }
    
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
    NSLog(@"Selected date = %@",date);
    self.labCheckIn.text = [date isoDateString];
    self.labCheckOut.text = [date isoDateString];
}

@end

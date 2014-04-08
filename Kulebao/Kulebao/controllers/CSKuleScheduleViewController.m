//
//  CSKuleScheduleViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleScheduleViewController.h"
#import "CSAppdelegate.h"

@interface CSKuleScheduleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labMonAm;
@property (weak, nonatomic) IBOutlet UILabel *labMonPm;
@property (weak, nonatomic) IBOutlet UILabel *labTueAm;
@property (weak, nonatomic) IBOutlet UILabel *labTuePm;
@property (weak, nonatomic) IBOutlet UILabel *labWedAm;
@property (weak, nonatomic) IBOutlet UILabel *labWedPm;
@property (weak, nonatomic) IBOutlet UILabel *labThuAm;
@property (weak, nonatomic) IBOutlet UILabel *labThuPm;
@property (weak, nonatomic) IBOutlet UILabel *labFriAm;
@property (weak, nonatomic) IBOutlet UILabel *labFriPm;

@end

@implementation CSKuleScheduleViewController

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
    
    [self updateScheduleInfo:nil];
    [self reloadSchedules];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - Private
- (void)reloadSchedules {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* scheduleInfos = [NSMutableArray array];
        
        for (id scheduleInfoJson in dataJson) {
            CSKuleScheduleInfo* scheduleInfo = [CSKuleInterpreter decodeScheduleInfo:scheduleInfoJson];
            [scheduleInfos addObject:scheduleInfo];
        }
        
        CSKuleScheduleInfo* schduleInfo = [scheduleInfos firstObject];
        if (schduleInfo) {
            [self updateScheduleInfo:schduleInfo];
            [gApp hideAlert];
            
            CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
            NSTimeInterval oldTimestamp = [gApp.engine.preferences timestampOfModule:kKuleModuleSchedule forChild:currentChild.childId];
            if (oldTimestamp < schduleInfo.timestamp) {
                [gApp.engine.preferences setTimestamp:schduleInfo.timestamp ofModule:kKuleModuleSchedule forChild:currentChild.childId];
            }
        }
        else {
            [gApp alert:@"没有课程表信息"];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    CSKuleChildInfo* currentChild = gApp.engine.currentRelationship.child;
    if (currentChild) {
        [gApp waitingAlert:@"获取信息中..."];
        [gApp.engine reqGetSchedulesOfKindergarten:gApp.engine.loginInfo.schoolId
                                       withClassId:currentChild.classId
                                           success:sucessHandler
                                           failure:failureHandler];
    }
    else {
        [gApp alert:@"没有宝宝信息。"];
    }
}

- (void)updateScheduleInfo:(CSKuleScheduleInfo*)schduleInfo {
    if (schduleInfo) {
        self.labMonAm.text = schduleInfo.week.mon.am;
        self.labMonPm.text = schduleInfo.week.mon.pm;
        self.labTueAm.text = schduleInfo.week.tue.am;
        self.labTuePm.text = schduleInfo.week.tue.pm;
        self.labWedAm.text = schduleInfo.week.wed.am;
        self.labWedPm.text = schduleInfo.week.wed.pm;
        self.labThuAm.text = schduleInfo.week.thu.am;
        self.labThuPm.text = schduleInfo.week.thu.pm;
        self.labFriAm.text = schduleInfo.week.fri.am;
        self.labFriPm.text = schduleInfo.week.fri.pm;
    }
    else {
        self.labMonAm.text = nil;
        self.labMonPm.text = nil;
        self.labTueAm.text = nil;
        self.labTuePm.text = nil;
        self.labWedAm.text = nil;
        self.labWedPm.text = nil;
        self.labThuAm.text = nil;
        self.labThuPm.text = nil;
        self.labFriAm.text = nil;
        self.labFriPm.text = nil;
    }
}

@end

//
//  CSKuleCheckinLogListViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCheckinLogListViewController.h"
#import "CSAppDelegate.h"
#import "CSKuleNoticeCell.h"
#import "CSKuleNewsDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "CSKuleCheckinLogTableViewCell.h"

@interface CSKuleCheckinLogListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation CSKuleCheckinLogListViewController
@synthesize checkInOutLogInfoList = _checkInOutLogInfoList;


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
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor clearColor];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _checkInOutLogInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleCheckinLogTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleCheckinLogTableViewCell"];
    
    CSKuleCheckInOutLogInfo* checkInOutLogInfo = [_checkInOutLogInfoList objectAtIndex:indexPath.row];
    
    cell.labTitle.text = [NSString stringWithFormat:@"%@家长，您好：", gApp.engine.loginInfo.username];
    
    CSKuleChildInfo* child = gApp.engine.currentRelationship.child;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp] isoDateTimeString];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    
    NSString* body = @"";
    
    switch (checkInOutLogInfo.noticeType) {
        case kKuleNoticeTypeCheckIn:
            body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 %@ 已于 %@  由 %@ 刷卡入园。", publiser, child.nick, timestampString, checkInOutLogInfo.parentName];
            break;
        case kKuleNoticeTypeCheckOut:
            body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 %@ 已于 %@ 由 %@ 刷卡离园。", publiser, child.nick, timestampString, checkInOutLogInfo.parentName];
            break;
        case kKuleNoticeTypeCheckInCarMorning:
        case kKuleNoticeTypeCheckInCarAfternoon:
            body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 %@ 已于 %@ 刷卡坐上校车。", publiser, child.nick, timestampString];
            break;
        case kKuleNoticeTypeCheckOutCarMorning:
        case kKuleNoticeTypeCheckOutCarAfternoon:
            body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 %@ 已于 %@ 刷卡离开校车。", publiser, child.nick, timestampString];
            break;
        default:
            body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 %@ 已于 %@ 刷卡(type=%@)。", publiser, child.nick, timestampString, @(checkInOutLogInfo.noticeType)];
            break;
    }
    
    cell.labDesc.text = body;
    
    if (checkInOutLogInfo.recordUrl.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:checkInOutLogInfo.recordUrl];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/0/w/50/h/50"];
        [cell.imgPhoto sd_setImageWithURL:qiniuImgUrl
                           placeholderImage:[UIImage imageNamed:@"img-placeholder.png"]];
    }
    else {
        [cell.imgPhoto cancelImageRequestOperation];
        cell.imgPhoto.image = [UIImage imageNamed:@"img-placeholder.png"];
    }
    cell.imgPhoto.clipsToBounds = YES;
    //cell.imgPhoto.layer.cornerRadius = 4;
    
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp];
    
    cell.labDate.text = [NSDate stringFromDate:timestamp withFormat:@"HH:mm"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSKuleCheckInOutLogInfo* checkInOutLogInfo = [_checkInOutLogInfoList objectAtIndex:indexPath.row];
    [self performSelector:@selector(showCheckInOutLogInfoDetails:) withObject:checkInOutLogInfo];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segue.checkInOutLogInfoDetails"]) {
        CSKuleNewsDetailsViewController* destCtrl = segue.destinationViewController;
        destCtrl.navigationItem.title = @"刷卡信息";
        destCtrl.checkInOutLogInfo = sender;
    }
}

#pragma mark - Private
- (void)showCheckInOutLogInfoDetails:(CSKuleCheckInOutLogInfo*)checkInOutLogInfo {
    [self performSegueWithIdentifier:@"segue.checkInOutLogInfoDetails" sender:checkInOutLogInfo];
}

#pragma mark - Setters
- (void)setCheckInOutLogInfoList:(NSMutableArray *)checkInOutLogInfoList {
    _checkInOutLogInfoList = checkInOutLogInfoList;
    if ([self isViewLoaded]) {
        [_tableview reloadData];
    }
}

@end

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
    CSKuleNoticeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNoticeCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleNoticeCell" owner:nil options:nil];
        cell = [nibs firstObject];
        cell.imgIcon.image = [UIImage imageNamed:@"icon-checkin.png"];
    }
    
    CSKuleCheckInOutLogInfo* checkInOutLogInfo = [_checkInOutLogInfoList objectAtIndex:indexPath.row];
    
    cell.labTitle.text = [NSString stringWithFormat:@"尊敬的用户 %@ 您好：", gApp.engine.loginInfo.username];
    
    CSKuleChildInfo* child = gApp.engine.currentRelationship.child;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp] isoDateTimeString];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    
    NSString* body = @"";
    if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckIn) {
        body = [NSString stringWithFormat:@"您的小孩 %@ 已于 %@  由 %@ 刷卡入园。", child.nick, timestampString, checkInOutLogInfo.parentName];
    }
    else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut){
        body = [NSString stringWithFormat:@"您的小孩 %@ 已于 %@ 由 %@ 刷卡离园。", child.nick, timestampString, checkInOutLogInfo.parentName];
    }
    
    cell.labContent.text = body;
    
    if (checkInOutLogInfo.recordUrl.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:checkInOutLogInfo.recordUrl];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/0/w/50/h/50"];
        [cell.imgAttachment setImageWithURL:qiniuImgUrl
                           placeholderImage:[UIImage imageNamed:@"chating-picture.png"]];
    }
    else {
        [cell.imgAttachment cancelImageRequestOperation];
        cell.imgAttachment.image = nil;
    }
    cell.imgAttachment.clipsToBounds = YES;
    cell.imgAttachment.layer.cornerRadius = 4;
    
    NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp];
    
    cell.labDate.text = [NSString stringWithFormat:@"%@ 来自:%@", [timestamp isoDateTimeString], publiser];
    cell.labPublisher.text = nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0+5.0;
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

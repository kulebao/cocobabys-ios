//
//  CSKuleNewsDetailsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsDetailsViewController.h"
#import "CSAppDelegate.h"
#import "BaiduMobStat.h"

@interface CSKuleNewsDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CSKuleNewsDetailsViewController
@synthesize newsInfo = _newsInfo;
@synthesize assignmentInfo = _assignmentInfo;
@synthesize checkInOutLogInfo = _checkInOutLogInfo;

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
    [self.webView hideGradientBackground];
    self.webView.scalesPageToFit = YES;
    [self reloadWebView];
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

#pragma mark - Setters
- (void)setNewsInfo:(CSKuleNewsInfo *)newsInfo{
    _newsInfo = newsInfo;
    _checkInOutLogInfo = nil;
    _assignmentInfo = nil;
    
    if ([self isViewLoaded]) {
        [self reloadWebView];
    }
}

- (void)setAssignmentInfo:(CSKuleAssignmentInfo *)assignmentInfo {
    _assignmentInfo = assignmentInfo;
    _checkInOutLogInfo = nil;
    _newsInfo = nil;
    
    if ([self isViewLoaded]) {
        [self reloadWebView];
    }
}

- (void)setCheckInOutLogInfo:(CSKuleCheckInOutLogInfo *)checkInOutLogInfo {
    _checkInOutLogInfo = checkInOutLogInfo;
    _assignmentInfo = nil;
    _newsInfo = nil;

    if ([self isViewLoaded]) {
        [self reloadWebView];
    }
}

#pragma mark - Private

- (void)reloadWebView {
    if (_newsInfo) {
        NSString* html = [self htmlWithNewsInfo:_newsInfo];
        [self.webView loadHTMLString:html baseURL:nil];
    }
    else if (_assignmentInfo) {
        NSString* html = [self htmlWithAssignmentInfo:_assignmentInfo];
        [self.webView loadHTMLString:html baseURL:nil];
    }
    else if (_checkInOutLogInfo) {
        NSString* html = [self htmlWithCheckInOutLogInfo:_checkInOutLogInfo];
        [self.webView loadHTMLString:html baseURL:nil];
    }
    else {
        [self.webView loadHTMLString:nil baseURL:nil];
    }
}

- (NSString*)htmlWithNewsInfo:(CSKuleNewsInfo*)newsInfo{
    static NSString* htmlTemp =
    @"<html>\
    <head>\
        <title>%@</title>\
        <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;' name='viewport' >\
    </head>\
    <body>\
        <div style='text-align:center;font-size:18pt;font-weight:bold'>%@</div>\
        <div style='text-align:center;font-size:10pt;'>%@ 来自:%@</div>\
        <p>\
        <div style='word-break:break-all;width:300;font-size:13pt'>%@</div>\
        %@\
    </body>\
    </html>";
    
    NSString* title = newsInfo.title;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp] isoDateTimeString];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    if (newsInfo.classId > 0 && newsInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser = [publiser stringByAppendingString:gApp.engine.currentRelationship.child.className];
    }
    
    NSString* body = newsInfo.content;
    
    NSString* divImage = @"";
    if (newsInfo.image.length > 0) {
        divImage = [NSString stringWithFormat:@"<div><img src='%@' width='300' /></div>", [gApp.engine urlFromPath:newsInfo.image]];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, title, title, timestampString, publiser, body, divImage];
    
    return ss;
}

- (NSString*)htmlWithAssignmentInfo:(CSKuleAssignmentInfo*)assignmentInfo{
    static NSString* htmlTemp =
    @"<html>\
    <head>\
    <title>%@</title>\
    <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;' name='viewport' >\
    </head>\
    <body>\
    <div style='text-align:center;font-size:18pt;font-weight:bold'>%@</div>\
    <div style='text-align:center;font-size:10pt;'>%@ 来自:%@</div>\
    <p>\
    <div style='word-break:break-all;width:300;font-size:13pt'>%@</div>\
    %@\
    </body>\
    </html>";
    
    NSString* title = assignmentInfo.title;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:assignmentInfo.timestamp] isoDateTimeString];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    if (assignmentInfo.classId > 0 && assignmentInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser = [publiser stringByAppendingString:gApp.engine.currentRelationship.child.className];
    }
    
    NSString* body = assignmentInfo.content;
    
    NSString* divImage = @"";
    if (assignmentInfo.iconUrl.length > 0) {
        divImage = [NSString stringWithFormat:@"<div><img src='%@' width='300' /></div>", [gApp.engine urlFromPath:assignmentInfo.iconUrl]];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, title, title, timestampString, publiser, body, divImage];
    
    return ss;
}

- (NSString*)htmlWithCheckInOutLogInfo:(CSKuleCheckInOutLogInfo*)checkInOutLogInfo{
    static NSString* htmlTemp =
    @"<html>\
    <head>\
    <title>%@</title>\
    <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;' name='viewport' >\
    </head>\
    <body>\
    <div style='text-align:left;font-size:13pt;font-weight:bold'>%@</div>\
    <p>\
    <div style='word-break:break-all;width:300;font-size:13pt'>%@</div>\
    <p>\
    <div style='text-align:right;font-size:13pt;'>%@</div>\
    <p>%@\
    </body>\
    </html>";
    
    NSString* title = [NSString stringWithFormat:@"尊敬的用户 %@ 你好:", gApp.engine.loginInfo.username];;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp] isoDateTimeString];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    
    NSString* body = @"";
    CSKuleChildInfo* child = gApp.engine.currentRelationship.child;
    if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckIn) {
        body = [NSString stringWithFormat:@"您的小孩 %@ 已于 %@ 刷卡入园。", child.name, timestampString];
    }
    else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut){
        body = [NSString stringWithFormat:@"您的小孩 %@ 已于 %@ 刷卡离园。", child.name, timestampString];
    }
    
    NSString* divImage = @"";
    if (checkInOutLogInfo.recordUrl.length > 0) {
        divImage = [NSString stringWithFormat:@"<div><img src='%@' width='300' /></div>", [gApp.engine urlFromPath:checkInOutLogInfo.recordUrl]];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, title, title, body, publiser, divImage];
    
    return ss;
}

@end

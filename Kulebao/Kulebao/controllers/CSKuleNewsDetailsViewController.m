//
//  CSKuleNewsDetailsViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-10.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleNewsDetailsViewController.h"
#import "CSAppDelegate.h"

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
        <div style='text-align:center;color:#cc6633'><h3>%@</h3></div>\
        <div style='text-align:center;'>%@</div>\
        <div style='text-align:center;'><h4>%@</h4></div>\
        <div style='word-break:break-all;width:300px'>%@</div>\
    </body>\
    </html>";
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp] isoDateTimeString];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    if (newsInfo.classId > 0 && newsInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser = [publiser stringByAppendingString:gApp.engine.currentRelationship.child.className];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, newsInfo.title, publiser, timestampString,  newsInfo.title, newsInfo.content];
    
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
    <div style='text-align:center;color:#cc6633'><h3>%@</h3></div>\
    <div style='text-align:center;word-break:break-all'>%@</div>\
    <div style='text-align:center;'><h4>%@</h4></div>\
    <div style='word-break:break-all;width:300px'>%@</div>\
    <div style='%@'><img src='%@' width='300' /></div>\
    </body>\
    </html>";
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:assignmentInfo.timestamp] isoDateTimeString];
    
    NSString* iconStyle = assignmentInfo.iconUrl ? @"" : @"visibility:hidden;";
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, assignmentInfo.title, assignmentInfo.publisher, timestampString,  assignmentInfo.title, assignmentInfo.content, iconStyle, assignmentInfo.iconUrl];
    
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
    <div style='text-align:center;color:#cc6633'><h3>%@</h3></div>\
    <div style='text-align:center;word-break:break-all'>%@</div>\
    <div style='text-align:left;'><h4>%@</h4></div>\
    <div style='word-break:break-all;width:300px'>%@</div>\
    <div style='%@'><img src='%@' width='300' /></div>\
    </body>\
    </html>";
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp] isoDateTimeString];
    
    NSString* iconStyle = checkInOutLogInfo.recordUrl ? @"" : @"visibility:hidden;";
    
    NSString* title = [NSString stringWithFormat:@"尊敬的用户 %@ 你好:", gApp.engine.loginInfo.username];
    
    NSString* content = @"";
    CSKuleChildInfo* child = gApp.engine.currentRelationship.child;
    if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckIn) {
        content = [NSString stringWithFormat:@"您的小孩 %@ 已于 %@ 刷卡入园。", child.name, timestampString];
    }
    else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut){
        content = [NSString stringWithFormat:@"您的小孩 %@ 已于 %@ 刷卡离园。", child.name, timestampString];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, gApp.engine.loginInfo.schoolName, gApp.engine.loginInfo.schoolName, timestampString,  title, content, iconStyle, checkInOutLogInfo.recordUrl];
    
    return ss;
}

@end

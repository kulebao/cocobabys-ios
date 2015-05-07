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

@interface CSKuleNewsDetailsViewController () <UIWebViewDelegate>
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
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self reloadWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_newsInfo) {
        [_newsInfo removeObserver:self forKeyPath:@"status"];
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:_newsInfo] && [keyPath isEqualToString:@"status"]) {
        [self updateNewsUI];
    }
}

- (void)updateNewsUI {
    if (self.newsInfo.feedbackRequired) {
        if (self.newsInfo.status == kNewsStatusMarking){
            [gApp waitingAlert:@"发送回执中"];
        }
        else if(self.newsInfo.status == kNewsStatusRead) {
            self.navigationItem.rightBarButtonItems = nil;
            [gApp hideAlert];
            [self customizeOkBarItemWithTarget:nil action:nil text:@"已回执"];
        }
        else {
            [self customizeOkBarItemWithTarget:self action:@selector(onMarkNews) text:@"发送回执"];
        }
    }
}

#pragma mark - Setters
- (void)setNewsInfo:(CSKuleNewsInfo *)newsInfo{
    _newsInfo = newsInfo;
    _checkInOutLogInfo = nil;
    _assignmentInfo = nil;
    
    if (_newsInfo) {
        [_newsInfo addObserver:self
                    forKeyPath:@"status"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    }
    
    [self updateNewsUI];
    
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

- (void)onMarkNews {
    [self.newsInfo markAsRead];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
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
        <div style='text-align:center;font-size:14pt;font-weight:bold'>%@</div>\
        <div style='text-align:center;font-size:10pt;'>%@ %@</div>\
        <p>\
        <div style='word-break:break-all;width:100%%;font-size:12pt'>%@</div>\
        %@\
    </body>\
    </html>";
    
    NSString* title = newsInfo.title;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp] timestampStringZhCN];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    if (newsInfo.classId > 0 && newsInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser = [publiser stringByAppendingString:gApp.engine.currentRelationship.child.className];
    }
    
    NSString* body = newsInfo.content;
    
    NSString* divImage = @"";
    if (newsInfo.image.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:newsInfo.image];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/2/w/720/h/720"];
        
        divImage = [NSString stringWithFormat:@"<div><img src='%@' width='100%%' /></div>", [qiniuImgUrl absoluteString]];
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
    <div style='text-align:center;font-size:14pt;font-weight:bold'>%@</div>\
    <div style='text-align:center;font-size:10pt;'>%@ 来自:%@</div>\
    <p>\
    <div style='word-break:break-all;width:100%%;font-size:12pt'>%@</div>\
    %@\
    </body>\
    </html>";
    
    NSString* title = assignmentInfo.title;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:assignmentInfo.timestamp] timestampStringZhCN];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    if (assignmentInfo.classId > 0 && assignmentInfo.classId == gApp.engine.currentRelationship.child.classId) {
        publiser = [publiser stringByAppendingString:gApp.engine.currentRelationship.child.className];
    }
    
    NSString* body = assignmentInfo.content;
    
    NSString* divImage = @"";
    if (assignmentInfo.iconUrl.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:assignmentInfo.iconUrl];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/2/w/720/h/720"];
        
        divImage = [NSString stringWithFormat:@"<div><img src='%@' width='100%%' /></div>", [qiniuImgUrl absoluteString]];
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
    <div style='word-break:break-all;width:100%%;font-size:13pt;font-weight:bold;text-indent:2em'>%@</div>\
    <p>\
    <div style='text-align:right;font-size:13pt;font-weight:bold'>%@</div>\
    <p>%@\
    </body>\
    </html>";
    
    NSString* title = [NSString stringWithFormat:@"尊敬的<font color='black'>%@</font>家长，您好:", gApp.engine.loginInfo.username];;
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:checkInOutLogInfo.timestamp] timestampStringZhCN];
    
    NSString* publiser = gApp.engine.loginInfo.schoolName;
    
    NSString* body = @"";
    CSKuleChildInfo* child = gApp.engine.currentRelationship.child;
    if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckIn) {
        body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 <font color='black'>%@</font> 已于 %@  由 <font color='black'>%@</font> 刷卡入园。", publiser, child.nick, timestampString, checkInOutLogInfo.parentName];
    }
    else if (checkInOutLogInfo.noticeType == kKuleNoticeTypeCheckOut){
        body = [NSString stringWithFormat:@"【%@】幼儿园提醒您，您的宝宝 <font color='black'>%@</font> 已于 %@ 由 <font color='black'>%@</font> 刷卡离园。", publiser, child.nick, timestampString, checkInOutLogInfo.parentName];
    }
    
    NSString* divImage = @"";
    if (checkInOutLogInfo.recordUrl.length > 0) {
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:checkInOutLogInfo.recordUrl];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/2/w/720/h/720"];
        
        divImage = [NSString stringWithFormat:@"<div><img src='%@' width='100%%' /></div>", [qiniuImgUrl absoluteString]];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, title, title, body, publiser, divImage];
    
    return ss;
}

@end

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
    _assignmentInfo = nil;
    
    if ([self isViewLoaded]) {
        [self reloadWebView];
    }
}

- (void)setAssignmentInfo:(CSKuleAssignmentInfo *)assignmentInfo {
    _assignmentInfo = assignmentInfo;
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
    else {
        [self.webView loadHTMLString:nil baseURL:nil];
    }
}

- (NSString*)htmlWithNewsInfo:(CSKuleNewsInfo*)newsInfo{
    static NSString* htmlTemp =
    @"<html>\
    <head>\
        <title>%@</title>\
    </head>\
    <body>\
        <div style='text-align:center;color:#cc6633'><h3>%@</h3></div>\
        <div style='text-align:center;'>%@</div>\
        <div style='text-align:center;'><h4>%@</h4></div>\
        <div >%@</div>\
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
    <div style='text-align:center;'>%@</div>\
    <div style='text-align:center;'><h4>%@</h4></div>\
    <div>%@</div>\
    <div style='%@'><img src='%@' width='300' /></div>\
    </body>\
    </html>";
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:assignmentInfo.timestamp] isoDateTimeString];
    
    NSString* iconStyle = assignmentInfo.iconUrl ? @"" : @"visibility:hidden;";
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, assignmentInfo.title, assignmentInfo.publisher, timestampString,  assignmentInfo.title, assignmentInfo.content, iconStyle, assignmentInfo.iconUrl];
    
    return ss;
}

@end

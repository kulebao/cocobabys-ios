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

    if (_newsInfo) {
        NSString* html = [self htmlWithNewsInfo:_newsInfo];
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
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
        <div>%@</div>\
    </body>\
    </html>";
    
    NSString* timestampString = [[NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp] isoDateTimeString];
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, newsInfo.title, gApp.engine.loginInfo.schoolName, timestampString,  newsInfo.title, newsInfo.content];
    
    return ss;
}

@end

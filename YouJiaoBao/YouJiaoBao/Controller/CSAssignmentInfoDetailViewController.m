//
//  CSAssignmentInfoDetailViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-10.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSAssignmentInfoDetailViewController.h"
#import "UIWebView+AFNetworking.h"
#import "UIWebView+CSKit.h"
#import "CSUtils.h"

@interface CSAssignmentInfoDetailViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation CSAssignmentInfoDetailViewController
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
    
    //[self customizeBackBarItem];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Private
- (void)reloadWebView {
    if (_assignmentInfo) {
        NSString* html = [self htmlWithAssignmentInfo:_assignmentInfo];
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (NSString*)htmlWithAssignmentInfo:(EntityAssignmentInfo*)assignmentInfo{
    static NSString* htmlTemp =
    @"<html>\
    <head>\
    <title>%@</title>\
    <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;' name='viewport' >\
    </head>\
    <body>\
    <div style='text-align:center;font-size:16pt;font-weight:bold;color:#cc6633'>%@</div>\
    <div style='text-align:center;font-size:10pt;color:#666666'>%@ %@</div>\
    <p>\
    <div style='word-break:break-all;width:100%%;font-size:13pt'>%@</div>\
    %@\
    </body>\
    </html>";
    
    NSString* title = assignmentInfo.title;
    
    NSString* timestampString = [CSUtils stringFromDateStyle1:[NSDate dateWithTimeIntervalSince1970:assignmentInfo.timestamp.doubleValue/1000.0]];
    
    NSString* publiser = _assignmentInfo.publisher;
    
    NSString* body = assignmentInfo.content;
    
    NSString* divImage = @"";
    if (assignmentInfo.iconUrl.length > 0) {
        NSURL* qiniuImgUrl = [NSURL URLWithString:assignmentInfo.iconUrl];
        
        divImage = [NSString stringWithFormat:@"<p><div><img src='%@' width='100%%' /></div>", [qiniuImgUrl absoluteString]];
    }
    
    NSString* ss = [NSString stringWithFormat:htmlTemp, title, title, timestampString, publiser, body, divImage];
    
    return ss;
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
}

@end

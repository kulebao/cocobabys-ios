//
//  CSNewsInfoDetailViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-9.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSNewsInfoDetailViewController.h"
#import "UIWebView+AFNetworking.h"
#import "UIWebView+CSKit.h"
#import "CSUtils.h"
#import "CSHttpClient.h"
#import "CSAppDelegate.h"
#import "CSEngine.h"
#import "CSNewsInfoReaderTableViewController.h"
#import "CSUtils.h"

@interface CSNewsInfoDetailViewController () <UIWebViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCheckList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDel;
- (IBAction)onBtnCheckListClicked:(id)sender;
- (IBAction)onBtnDelClicked:(id)sender;

@end

@implementation CSNewsInfoDetailViewController
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
    //
    
    self.btnCheckList.tintColor = [UIColor whiteColor];
    self.btnDel.tintColor = [UIColor whiteColor];
    
    if (self.newsInfo.feedback_required.integerValue > 0) {
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.news.reader"]) {
        CSNewsInfoReaderTableViewController* ctrl = segue.destinationViewController;
        ctrl.newsInfo = self.newsInfo;
        ctrl.readerList = sender;
    }
}

#pragma mark - Private
- (NSString*)tagTitle {
    NSString* tTitle = @"园内公告";
    NSString* tags = [self.newsInfo.tags componentsJoinedByString:@" "];
    NSRange range = [tags rangeOfString:@"作业"];
    if (range.length > 0) {
        tTitle = @"亲子作业";
    }
    else if(self.newsInfo.class_id.integerValue > 0) {
        tTitle = @"班级通知";
    }
    
    return tTitle;
}
- (void)reloadWebView {
    if (_newsInfo) {
        NSString* html = [self htmlWithNewsInfo:_newsInfo];
        [self.webView loadHTMLString:html baseURL:nil];
        
        self.navigationItem.title = [self tagTitle];
    }
}

- (void)setNewsInfo:(CBNewsInfo *)newsInfo {
    _newsInfo = newsInfo;
    [self reloadWebView];
}

- (NSString*)htmlWithNewsInfo:(CBNewsInfo*)newsInfo{
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
    
    NSString* title = newsInfo.title;
    
    NSString* timestampString = [CSUtils stringFromDateStyle1:[NSDate dateWithTimeIntervalSince1970:newsInfo.timestamp.doubleValue/1000.0]];
    
    NSString* publiser = @"";
    if (newsInfo.class_id.integerValue > 0) {
        CBSessionDataModel* session = [CBSessionDataModel thisSession];
        CBClassInfo* classInfo = [session getClassInfoByClassId:newsInfo.class_id.integerValue];
        if (classInfo.name.length > 0) {
            publiser = classInfo.name;
        }
    }
    
    NSString* body = [newsInfo.content stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
    body = [body stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    
    NSString* divImage = @"";
    if (newsInfo.image.length > 0) {
        NSURL* qiniuImgUrl = [NSURL URLWithString:newsInfo.image];
        
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

#pragma mark - UI
- (IBAction)onBtnCheckListClicked:(id)sender {
    CSLog(@"%s", __FUNCTION__);
    
    //    if (self.newsInfo.classId.integerValue > 0) {
    //        CSLog(@"班级 %@", self.newsInfo.classId);
    //    }
    //    else {
    //        CSLog(@"全园");
    //    }
    
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        [gApp hideAlert];
        
        NSArray* readers = [session updateParentInfosByJsonObject:responseObject];
        //CSLog(@"readers = %@", readers);
        [self openReaderList:readers];
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        [gApp hideAlert];
    };
    
    [gApp waitingAlert:@"正在查询回执情况..."];
    [http opGetNewsReaders:self.newsInfo.news_id
            inKindergarten:session.loginInfo.school_id.integerValue
                   success:success
                   failure:failure];
}

- (IBAction)onBtnDelClicked:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确定删除本文？删除后不可恢复！"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"删除", nil];
    alert.delegate = self;
    [alert show];
}

- (void)openReaderList:(NSArray*)readerList {
    [self performSegueWithIdentifier:@"segue.news.reader" sender:readerList];
}

- (void)doDeleteNews {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CBSessionDataModel* session = [CBSessionDataModel thisSession];
    
    id success = ^(NSURLSessionDataTask *task, id responseObject) {
        [gApp hideAlert];
        
        NSInteger error_code = 0;
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            error_code = [[responseObject objectForKey:@"error_code"] integerValue];
        }
        
        if (error_code == 0) {
            [session.newsInfoList removeObject:self.newsInfo];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSString* msg = [NSString stringWithFormat:@"权限不足，删除失败，无法删除%@", [self tagTitle]];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    };
    
    id failure = ^(NSURLSessionDataTask *task, NSError *error) {
        [gApp hideAlert];
        
        NSHTTPURLResponse* response = (NSHTTPURLResponse*) task.response;
        
        if (response.statusCode == 403) {
            NSString* msg = [NSString stringWithFormat:@"权限不足，删除失败，无法删除%@", [self tagTitle]];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            [gApp alert:[NSString stringWithFormat:@"删除失败(%ld)", response.statusCode]];
        }
    };
    
    [gApp waitingAlert:@"正在删除数据"];
    [http opDeleteNews:self.newsInfo.news_id
        inKindergarten:session.loginInfo.school_id.integerValue
               success:success
               failure:failure];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self doDeleteNews];
    }
}

@end

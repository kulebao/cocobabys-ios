//
//  CSKuleFeedbackViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-4-6.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleFeedbackViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleFeedbackViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView* viewContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgContentBg;
@property (weak, nonatomic) IBOutlet UITextView *textMsgBody;
@property (weak, nonatomic) IBOutlet UILabel *labTips;

@end

@implementation CSKuleFeedbackViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(onBtnSendClicked:)];
    
    self.imgContentBg.image = [[UIImage imageNamed:@"v2-input_bg_家园互动.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    self.textMsgBody.delegate = self;
    [self.textMsgBody becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
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

#pragma mark - UI Actions
- (void)onBtnSendClicked:(id)sender {
    [self.textMsgBody resignFirstResponder];
    
    NSString* msgBody = self.textMsgBody.text;
    if (msgBody.length > 0) {
        [self doSendText:msgBody];
    }
    else {
        [gApp alert:@"不能发送空内容 ^_^"];
    }
}

- (void)doSendText:(NSString*)msgBody {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        /* {"error_msg":"","error_code":1} */
        NSString* error_msg = [dataJson valueForKeyNotNull:@"error_msg"];
        NSInteger error_code = [[dataJson valueForKeyNotNull:@"error_code"] integerValue];
        
        if (error_code == 0) {
            [gApp alert:@"谢谢您的反馈。"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [gApp alert:error_msg];
        }
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
     };
    
    [gApp waitingAlert:@"正在提交反馈..."];
    [gApp.engine.httpClient reqSendFeedback:gApp.engine.loginInfo.accountName
                     withContent:msgBody
                         success:sucessHandler
                         failure:failureHandler];

}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self reloadTips];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self reloadTips];
}

- (void)reloadTips {
    if (self.textMsgBody.text.length > 0) {
        self.labTips.hidden = YES;
    }
    else {
        self.labTips.hidden = NO;
    }
}

@end

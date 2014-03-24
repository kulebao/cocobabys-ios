//
//  CSKuleChatingEditorViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-24.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingEditorViewController.h"
#import "CSAppDelegate.h"

@interface CSKuleChatingEditorViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textMsgBody;

@end

@implementation CSKuleChatingEditorViewController
@synthesize delegate = _delegate;

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
    
    [self customizeOkBarItemWithTarget:self
                                   action:@selector(onBtnSendClicked:)
                                     text:@"发送"];
    
    self.textMsgBody.backgroundColor = [UIColor clearColor];
    [self.textMsgBody becomeFirstResponder];
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

#pragma mark - UI Actions
- (void)onBtnSendClicked:(id)sender {
    [self.textMsgBody resignFirstResponder];
    
    NSString* msgBody = self.textMsgBody.text;
    if (msgBody.length > 0) {
        [self doSendText:msgBody];
    }
    else {
        [gApp alert:@"不能发送空消息 ^_^"];
    }
}

- (void)doSendText:(NSString*)msgBody {
    if ([_delegate respondsToSelector:@selector(willSendMsgWithText:)]) {
        [_delegate willSendMsgWithText:msgBody];
    }
}

@end

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

@end

@implementation CSKuleChatingEditorViewController

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
    
    [self customizeRightBarItemWithTarget:self
                                   action:@selector(onBtnSendClicked:)
                                   normal:[UIImage imageNamed:@""]
                               hightlight:[UIImage imageNamed:@""]
                                     text:@"发送"];
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
    
}

@end

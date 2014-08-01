//
//  CSRootViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-5.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSRootViewController.h"
#import "CSEngine.h"
#import "EntityLoginInfoHelper.h"

@interface CSRootViewController ()

@end

@implementation CSRootViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSuccess:) name:@"noti.login.success" object:nil];
    
    [self checkLocalData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

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

- (void)checkLocalData {
    NSFetchedResultsController* frCtrl = [EntityLoginInfoHelper frRecentLoginUser];
    NSError* error = nil;
    BOOL ok = [frCtrl performFetch:&error];
    if (ok && frCtrl.fetchedObjects.count > 0) {
        [[CSEngine sharedInstance] onLogin:frCtrl.fetchedObjects.lastObject];
        [self showMainView];
    }
    else {
        [self showLoginView];
    }
}

- (void)showLoginView {
    [self performSegueWithIdentifier:@"segue.root.login" sender:nil];
}

- (void)showMainView {
    [self performSegueWithIdentifier:@"segue.root.main" sender:nil];
}

- (void)onLoginSuccess:(NSNotification*)noti {
    [[CSEngine sharedInstance] onLogin:noti.object];
    [self showMainView];
}

@end
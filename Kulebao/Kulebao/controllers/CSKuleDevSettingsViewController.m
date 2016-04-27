//
//  CSKuleDevSettingsViewController.m
//  youlebao
//
//  Created by xin.c.wang on 15/2/5.
//  Copyright (c) 2015-2016 Cocobabys. All rights reserved.
//

#import "CSKuleDevSettingsViewController.h"
#import "CSKulePreferences.h"
#import "CSAppDelegate.h"

@interface CSKuleDevSettingsViewController () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labServerName;
@property (weak, nonatomic) IBOutlet UIButton *btnSwitchServer;
@property (nonatomic, strong) NSArray* serverList;

- (IBAction)onBtnSwitchServerClicked:(id)sender;
- (IBAction)onBtnBackClicked:(id)sender;

@end

@implementation CSKuleDevSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CSKulePreferences* preference = [CSKulePreferences defaultPreferences];
    self.serverList = [preference getSupportServerSettingsList];
    
    [self updateContent];
}

- (void)didReceiveMemoryWarning {
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnSwitchServerClicked:(id)sender {
    UIActionSheet* actSheet = [[UIActionSheet alloc] initWithTitle:@"请选择服务器" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSDictionary* serverInfo in self.serverList) {
        [actSheet addButtonWithTitle:serverInfo[@"name"]];
    }
    
    [actSheet showInView:self.view];
}

- (IBAction)onBtnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateContent {
    CSKulePreferences* preference = [CSKulePreferences defaultPreferences];
    NSDictionary* serverInfo = [preference getServerSettings];
    self.labServerName.text = serverInfo[@"name"];
}

- (void)alertToExit {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"服务器切换成功，程序即将退出"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"退出程序", nil];
    
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        exit(0);
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    CSKulePreferences* preference = [CSKulePreferences defaultPreferences];
    NSDictionary* oldServerInfo = [preference getServerSettings];
    for (NSDictionary* serverInfo in self.serverList) {
        if ([serverInfo[@"name"] isEqualToString:btnTitle]) {
            //[preference setServerSettings:serverInfo];
            preference.configTag = serverInfo[@"tag"];
            [self updateContent];
            
            if (![oldServerInfo isEqualToDictionary:serverInfo]) {
                [self alertToExit];
            }
        }
    }
}

@end

//
//  CSKuleCCTVMainTableViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-12.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleCCTVMainTableViewController.h"
#import "hm_sdk.h"
#import "CSKuleCCTVPlayViewController.h"
#import "CSAppDelegate.h"
#import "HMPlayerView.h"
#import "CSKuleCCTVItemTableViewCell.h"
#import "BaiduMobStat.h"

@interface CSKuleCCTVMainTableViewController () <UIAlertViewDelegate> {
    NSMutableArray* _deviceList;
    P_USER_INFO _pUserInfo;
    
    node_handle _rootNodeHandle;
    tree_handle _treeHandle;
}

@end

@implementation CSKuleCCTVMainTableViewController
@synthesize videoMember = _videoMember;
@synthesize isTrail = _isTrail;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self customizeBackBarItem];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    if(self.isTrail) {
        UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        tipLabel.text = @"宝宝所在的幼儿园暂未开通此功能，该实时视频仅供演示，如需要开通，请联系幼儿园。";
        tipLabel.numberOfLines = 2;
        tipLabel.font = [UIFont systemFontOfSize:12.0];
        self.tableView.tableHeaderView = tipLabel;
    }
    
    _treeHandle = NULL;
    
    [self performSelector:@selector(hmLogin) withObject:nil afterDelay:0];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (_treeHandle!=NULL) {
        hm_server_release_tree(_treeHandle);
        _treeHandle = NULL;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    //[self setNeedsStatusBarAppearanceUpdate];
    
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _deviceList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSKuleCCTVItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleCCTVItemTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary* deviceInfo = [_deviceList objectAtIndex:indexPath.row];
    
    node_handle cur_node = [deviceInfo[@"node_handle"] pointerValue];
    
    bool isOnline = false;
    hm_server_is_online(cur_node, &isOnline);
    if (isOnline) {
        cell.labDeviceName.text = [NSString stringWithFormat:@"%@ (在线)", deviceInfo[@"name"]];
    }
    else {
        cell.labDeviceName.text = [NSString stringWithFormat:@"%@ (离线)", deviceInfo[@"name"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* deviceInfo = [_deviceList objectAtIndex:indexPath.row];
    
    node_handle cur_node = [deviceInfo[@"node_handle"] pointerValue];
    
    NODE_TYPE_INFO type;
    hm_server_get_node_type(cur_node,&type);
    
    if(type == HME_NT_DEVICE) {
        bool isOnline = false;
        hm_server_is_online(cur_node, &isOnline);
        if (!isOnline) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"设备不在线"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
            [alert show];
        }
        else {
            HMPlayerView* playerView = [[HMPlayerView alloc] initWithNibName:@"HMPlayerView" bundle:nil];
            playerView.isTrail = self.isTrail;
            playerView.curNode = cur_node;
            
            [self presentViewController:playerView
                               animated:YES
                             completion:^{
                             }];
        }
    }
    else {
        CSLog(@"不支持的NODE_TYPE_INFO(%d)", type);
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.cctv.play"]) {
        CSKuleCCTVPlayViewController* ctrl = segue.destinationViewController;
        ctrl.deviceMeta = sender;
        ctrl.isTrail = self.isTrail;
    }
}

#pragma mark - Private
- (hm_result)hmLogin {
    hm_result result = HMEC_OK;
    
    LOGIN_SERVER_INFO serverinfo;
    serverinfo.ip = "www.seebaobei.com";
    serverinfo.port = 80;
    serverinfo.hard_ver = "iPhone";
    serverinfo.soft_ver = "v2.4.x";
    serverinfo.plat_type = "ios";

    char account[128] = {0};
    char password[128] = {0};
    
    [_videoMember.account getCString:account maxLength:128 encoding:NSUTF8StringEncoding];
    [_videoMember.password getCString:password maxLength:128 encoding:NSUTF8StringEncoding];
    serverinfo.user = account;
    serverinfo.password = password;
    serverinfo.keep_time = 60;
    
    char err[512] = {0};
    
    [gApp waitingAlert:@"连接服务器"];
    // step 1: Connect the server.
    if (gApp.engine.hmServerId != NULL) {
        hm_server_disconnect(gApp.engine.hmServerId);
        gApp.engine.hmServerId = NULL;
        CSLog(@"退出成功");
    }
    
    server_id serverId = NULL;
    result =  hm_server_connect(&serverinfo, &serverId, err, 512);
    if (result == HMEC_OK) {
        gApp.engine.hmServerId = serverId;
        [self performSelector:@selector(hmGetDeviceList) withObject:nil afterDelay:0];
        
    }else{
        gApp.engine.hmServerId = NULL;
        /*
        NSString* errorString = [[NSString alloc] initWithCString:err encoding:NSUTF8StringEncoding];
        [gApp alert:[NSString stringWithFormat:@"连接失败(%d): %@", result, errorString]];
         */
        [gApp hideAlert];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录视频服务器失败，请稍后重试！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        alert.tag = 1001;
        [alert show];
    }
    
    return result;
}

- (hm_result)hmGetDeviceList {
    [gApp waitingAlert:@"获取列表"];
    hm_result result = hm_server_get_device_list(gApp.engine.hmServerId);
    if (result == HMEC_OK) {
        //getTime
        uint64 time;
        hm_server_get_time(gApp.engine.hmServerId, &time);
        if(time >= HMEC_OK) {
            // step 2: Get user information.
            result = hm_server_get_user_info(gApp.engine.hmServerId, &_pUserInfo);
            if (result == HMEC_OK && _pUserInfo != NULL) {
                // step 3: Get transfer service.
                if (_pUserInfo->use_transfer_service != HMEC_OK) {
                    [gApp waitingAlert:@"获取穿透信息"];
                    result = hm_server_get_transfer_info(gApp.engine.hmServerId);
                    if (result != HMEC_OK) {
                        CSLog(@"获取穿透信息失败");
                    }
                    [gApp hideAlert];
                }
                
                if (result == HMEC_OK) {
                    [gApp waitingAlert:@"获取列表"];
                    
                    if (_treeHandle!=NULL) {
                        hm_server_release_tree(_treeHandle);
                        _treeHandle = NULL;
                    }
                    
                    result = hm_server_get_tree(gApp.engine.hmServerId, &_treeHandle);
                    result = hm_server_get_root(_treeHandle, &_rootNodeHandle);
                    
                    int32 deviceCount = 0;
                    hm_server_get_all_device_count(_treeHandle, &deviceCount);
                    _deviceList = [NSMutableArray arrayWithCapacity:deviceCount];
                    
                    if (deviceCount == 0) {
                        [gApp alert:@"没有设备"];
                    }
                    else {
                        [gApp alert:@"获取成功"];
                        for (int32 i =0; i<deviceCount; i++) {
                            node_handle node = NULL;
                            hm_server_get_all_device_at(_treeHandle, i, &node);
                            if (node != NULL) {
                                cpchar name = NULL;
                                hm_server_get_node_name(node, &name);
                                
                                CSLog(@"device tree node %d: name:%@", i, @(name));
                                
                                [_deviceList addObject:@{@"name": @(name),
                                                         @"node_handle": [NSValue valueWithPointer:node]
                                                         }];
                            }
                        }
                    }
                }
                else {
                    [gApp alert:[NSString stringWithFormat:@"获取穿透信息失败(%d)", result]];
                }
            }
            else {
                [gApp alert:[NSString stringWithFormat:@"获取用户信息失败(%d)", result]];
            }
        }
        else { // Get time
            
        }
    }
    else{
        [gApp alert:[NSString stringWithFormat:@"获取列表失败(%d)", result]];
    }
    
    [self.tableView reloadData];
    return result;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

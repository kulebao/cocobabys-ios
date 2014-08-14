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

@interface CSKuleCCTVMainTableViewController () {
    NSMutableArray* _deviceList;
    
    server_id _serverId;
    P_USER_INFO _pUserInfo;
    
    node_handle _rootNodeHandle;
    tree_handle _treeHandle;
}

@end

@implementation CSKuleCCTVMainTableViewController

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
    
    [self performSelector:@selector(hmLogin) withObject:nil afterDelay:0];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    // Configure the cell...
    NSDictionary* deviceInfo = [_deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = deviceInfo[@"name"];
    
    cell.imageView.image = [UIImage imageNamed:@"record.png"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* deviceInfo = [_deviceList objectAtIndex:indexPath.row];
    
    node_handle cur_node = [deviceInfo[@"node_handle"] pointerValue];
    
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
    
    HMPlayerView* playerView = [[HMPlayerView alloc] initWithNibName:@"HMPlayerView" bundle:nil];
    [self.navigationController pushViewController:playerView animated:YES];
    [playerView ConnectVideoBynode:cur_node];
    
    //[self performSegueWithIdentifier:@"segue.cctv.play" sender:deviceInfo];
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
    }
}

#pragma mark - Private
- (hm_result)hmLogin {
    hm_result result = HMEC_OK;
    
    LOGIN_SERVER_INFO serverinfo;
    serverinfo.ip = "www.seebaobei.com";
    serverinfo.port = 80;
    serverinfo.hard_ver = "iPhone";
    serverinfo.soft_ver = "1.3";
    serverinfo.plat_type = "ios";
    serverinfo.user = "2222";
    serverinfo.password = "6yWw2D";
    
    pchar err = "";
    
    [gApp waitingAlert:@"连接服务器"];
    // step 1: Connect the server.
    result =  hm_server_connect(&serverinfo, &_serverId, err);
    if (result == HMEC_OK) {
        [self performSelector:@selector(hmGetDeviceList) withObject:nil afterDelay:0];
        
    }else{
        [gApp alert:[NSString stringWithFormat:@"连接失败(%d)", result]];
    }
    
    return result;
}

- (hm_result)hmGetDeviceList {
    hm_result result = HMEC_OK;
    [gApp waitingAlert:@"获取列表"];
    result = hm_server_get_device_list(_serverId);
    
    if (result == HMEC_OK) {
        // step 2: Get user information.
        result = hm_server_get_user_info(_serverId, &_pUserInfo);
        if (result == HMEC_OK) {
            // step 3: Get transfer service.
            if (_pUserInfo->use_transfer_service != HMEC_OK) {
                [gApp waitingAlert:@"获取穿透信息"];
                result = hm_server_get_transfer_info(_serverId);
            }
            
            if (result == HMEC_OK) {
                [gApp waitingAlert:@"获取列表"];
                
                result = hm_server_get_tree(_serverId, &_treeHandle);
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
                
            }else {
                [gApp alert:[NSString stringWithFormat:@"获取穿透信息失败(%d)", result]];
            }
        }
        else {
            [gApp alert:[NSString stringWithFormat:@"获取用户信息失败(%d)", result]];
        }
    }else{
        [gApp alert:[NSString stringWithFormat:@"获取列表(%d)", result]];
    }
    
    
    [self.tableView reloadData];
    
    return result;
}

@end

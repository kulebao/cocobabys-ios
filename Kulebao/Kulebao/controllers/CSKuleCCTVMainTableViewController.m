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

@interface CSKuleCCTVMainTableViewController () {
    NSMutableArray* _deviceList;
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
    
    hm_result result = 0;
    
    result = hm_sdk_init();
    if (result == HMEC_OK) {
        LOGIN_SERVER_INFO serverinfo;
        serverinfo.ip = "www.seebaobei.com";
        serverinfo.port = 80;
        serverinfo.hard_ver = "iPhone";
        serverinfo.soft_ver = "1.3";
        serverinfo.plat_type = "ios";
        serverinfo.user = "xmm";
        serverinfo.password = "123456";
        
        server_id hserver = NULL;
        pchar err = "";
        
        // step 1: Connect the server.
        result =  hm_server_connect(&serverinfo, &hserver, err);
        if (result == HMEC_OK) {
            result = hm_server_get_device_list(hserver);
            if (result == HMEC_OK) {
                // step 2: Get user information.
                P_USER_INFO userInfo;
                result = hm_server_get_user_info(hserver, &userInfo);
                if (result == HMEC_OK) {
                    // step 3: Get transfer service.
                    if (userInfo->use_transfer_service != 0) {
                        result = hm_server_get_transfer_info(hserver);
                        if (result == HMEC_OK) {
                            tree_handle tree = NULL;
                            result = hm_server_get_tree(hserver, &tree);
                            if (result == HMEC_OK) {
                                node_handle node = NULL;
                                hm_server_get_root(tree, &node);
                                int32 deviceCount = 0;
                                hm_server_get_all_device_count(tree, &deviceCount);
                                _deviceList = [NSMutableArray arrayWithCapacity:deviceCount];
                                
                                for (int32 i =0; i<deviceCount; i++) {
                                    node = NULL;
                                    hm_server_get_all_device_at(tree, i, &node);
                                    if (node != NULL) {
                                        cpchar name = NULL;
                                        hm_server_get_node_name(node, &name);
                                        
                                        CSLog(@"device tree node %d: name:%s", i, name);
                                        
                                        [_deviceList addObject:@{@"name": @(name),
                                                                 @"node_handle": [NSValue valueWithPointer:node]
                                                                 }];
                                        
                                        CSLog(@"");
                                        
                                    }
                                }
                            }
                            else {
                                CSLog(@"hm_server_get_tree error: %d", result);
                            }
                        }
                        else {
                            CSLog(@"hm_server_get_transfer_info error: %d", result);
                        }
                    }
                }
                else {
                    CSLog(@"hm_server_get_user_info error: %d", result);
                }
            }
            else {
                CSLog(@"hm_server_get_device_list error: %d", result);
            }
        }
        else {
            CSLog(@"hm_server_connect error: %d", result);
        }
    }
    
    else {
        CSLog(@"hm_sdk_init error: %d", result);
    }
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

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* deviceInfo = [_deviceList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segue.cctv.play" sender:deviceInfo];
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
        ctrl.deviceInfo = sender;
    }
}

@end

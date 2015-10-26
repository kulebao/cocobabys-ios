//
//  CSKuleSettings2ViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/26/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CSKuleSettings2ViewController.h"
#import "AHAlertView.h"
#import "CSAppDelegate.h"
#import "UIImageView+WebCache.h"

@interface CSKuleSettings2ViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDev;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIImageView *imgPortrait;
- (IBAction)onBtnPortraitClicked:(id)sender;

@end

@implementation CSKuleSettings2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self customizeBackBarItem];
    self.imgPortrait.layer.cornerRadius = self.imgPortrait.bounds.size.width/2.0;
    self.imgPortrait.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    self.labName.text = [NSString stringWithFormat:@"%@ %@\n%@", gApp.engine.currentRelationship.relationship, gApp.engine.currentRelationship.parent.name, gApp.engine.currentRelationship.parent.phone];
    
    NSURL* qiniuImgUrl = [gApp.engine urlFromPath:gApp.engine.currentRelationship.parent.portrait];
    qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/256/h/256"];
    
    [self.imgPortrait sd_setImageWithURL:qiniuImgUrl
                        placeholderImage:[UIImage imageNamed:@"chat_head_icon.gif"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 2;
    if (COCOBABYS_DEV_MODEL) {
        numberOfSections = 3;
    }
    return numberOfSections;
}


#if 0
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section==1 && row==4) {
        // Exit
        [self onLogoutClicked];
    }
    else if (section==2 && row==0) {
        // DEV
    }
}

- (void)onLogoutClicked {
    NSString *title = @"提示";
    NSString *message = @"确定要退出登录？退出后无法接收任何消息！";
    
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:@"取消" block:^{
    }];
    
    [alert addButtonWithTitle:@"确定" block:^{
        [self performSelector:@selector(doLogout) withObject:nil];
    }];
    
    [alert show];
}

#pragma mark - Private
- (void)doLogout {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        CSKuleBindInfo* bindInfo = [CSKuleInterpreter decodeBindInfo:dataJson];
        if (bindInfo.errorCode == 0) {
            [gApp hideAlert];
        }
        else {
            CSLog(@"doReceiveBindInfo error_code=%d", bindInfo.errorCode);
            [gApp alert:@"解除绑定失败。"];
        }
        
        [gApp logout];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
        [gApp logout];
    };
    
    [gApp waitingAlert:@"注销登录..."];
    [gApp.engine reqUnbindWithSuccess:sucessHandler failure:failureHandler];
}

- (IBAction)onBtnPortraitClicked:(id)sender {
}
@end

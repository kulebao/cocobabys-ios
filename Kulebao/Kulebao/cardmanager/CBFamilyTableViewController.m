//
//  CBFamilyTableViewController.m
//  youlebao
//
//  Created by xin.c.wang on 10/27/15.
//  Copyright © 2015 Cocobabys. All rights reserved.
//

#import "CBFamilyTableViewController.h"
#import "CSAppDelegate.h"
#import "CBFamilyItemTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CBShareIntroView.h"

@interface CBFamilyTableViewController ()

@property (nonatomic, strong) NSMutableArray* relationships;
- (IBAction)onBtnShareClicked:(id)sender;

@property (nonatomic, strong) CBShareIntroView* shareIntroView;

@end

@implementation CBFamilyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self customizeBackBarItem];
    self.tableView.rowHeight = 54;
    
    self.relationships = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadChildRelationships];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = self.relationships.count;
    }
    else {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CBFamilyItemTableViewCell* cell = nil;
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CBFamilyItemTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CSKuleRelationshipInfo* relationshipInfo = [self.relationships objectAtIndex:row];
        cell.labName.text = [NSString stringWithFormat:@"%@ %@", relationshipInfo.relationship, relationshipInfo.parent.name];
        cell.labPhone.text = relationshipInfo.parent.phone;
        
        cell.imgIcon.layer.cornerRadius = cell.imgIcon.bounds.size.width/2;
        
        NSURL* qiniuImgUrl = [gApp.engine urlFromPath:relationshipInfo.parent.portrait];
        qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/128/h/128"];
        [cell.imgIcon sd_cancelCurrentImageLoad];
        [cell.imgIcon sd_setImageWithURL:qiniuImgUrl
                        placeholderImage:[UIImage imageNamed:@"v2-small"]];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CBFamilyItemTableViewCell2" forIndexPath:indexPath];
        cell.imgIcon.image = [UIImage imageNamed:@"v2-small"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    if (section==0) {
    }
    else if (section==1) {
        [self performSegueWithIdentifier:@"segue.addfamily" sender:nil];
    }
}

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

#pragma mark - Network
- (void)reloadChildRelationships {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        [self.relationships removeAllObjects];
        for (id relationshipJson in dataJson) {
            CSKuleRelationshipInfo* relationshipInfo = [CSKuleInterpreter decodeRelationshipInfo:relationshipJson];
            if (relationshipInfo.parent && relationshipInfo.child) {
                [self.relationships addObject:relationshipInfo];
            }
        }
        
        [gApp hideAlert];
        [self.tableView reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    //[gApp waitingAlert:@"获取家人信息"];
    [gApp.engine.httpClient reqGetChildRelationship:gApp.engine.currentRelationship.child.childId
                          inKindergarten:gApp.engine.loginInfo.schoolId
                                 success:sucessHandler
                                 failure:failureHandler];
}

- (IBAction)onBtnShareClicked:(id)sender {
    [self showIntroViews];
}

- (CBShareIntroView*)shareIntroView {
    if (_shareIntroView == nil) {
        _shareIntroView = [CBShareIntroView instance];
    }
    
    return _shareIntroView;
}

-(void)showIntroViews {
    [self.shareIntroView showInView:self.navigationController.view];
}

@end

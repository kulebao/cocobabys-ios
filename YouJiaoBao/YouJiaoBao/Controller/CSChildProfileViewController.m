//
//  CSChildProfileViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-7.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSChildProfileViewController.h"
#import "CSChildProfileHeaderViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "EntityRelationshipInfoHelper.h"
#import "CSChildRelationshipItemTableViewCell.h"
#import "CSAssessmentEditorViewController.h"
#import "CBIMDataSource.h"
#import "CBIMChatViewController.h"
#import "EntityParentInfo.h"

@interface CSChildProfileViewController () <UITableViewDataSource, UITableViewDelegate, CSChildProfileHeaderViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* childRelationships;

@end

@implementation CSChildProfileViewController
@synthesize childInfo = _childInfo;
@synthesize childRelationships = _childRelationships;

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
    //[self customizeBackBarItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectNull];
    
    [self reloadRelationships];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue.childprofile.header"]) {
        CSChildProfileHeaderViewController* ctrl = [segue destinationViewController];
        ctrl.childInfo = self.childInfo;
        ctrl.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"segue.childprofile.assessment"]) {
        CSAssessmentEditorViewController* ctrl = [segue destinationViewController];
        ctrl.childInfo = self.childInfo;
    }
    else if ([segue.identifier isEqualToString:@"segue.childprofile.chating"]) {
    }
}

#pragma mark - Private
- (void)reloadRelationships {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    //CSEngine* engine = [CSEngine sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id jsonObjectList) {
        self.childRelationships = [EntityRelationshipInfoHelper updateEntities: jsonObjectList];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
    };
    
    [http opGetRelationshipOfChild:self.childInfo.childId
                    inKindergarten:self.childInfo.schoolId.integerValue
                           success:success
                           failure:failure];

}

- (void)setChildRelationships:(NSArray *)childRelationships {
    _childRelationships = childRelationships;
    
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = _childRelationships.count;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSChildRelationshipItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSChildRelationshipItemTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    EntityRelationshipInfo* relationship = [_childRelationships objectAtIndex:indexPath.row];
    cell.relationship = relationship;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EntityRelationshipInfo* relationship = [_childRelationships objectAtIndex:indexPath.row];
    
    NSString* userId = [NSString stringWithFormat:@"p_%@_Some(%@)_%@", relationship.childInfo.schoolId, relationship.parentInfo.uid, relationship.parentInfo.phone];
    if([[[[RCIMClient sharedRCIMClient] currentUserInfo] userId] isEqualToString:userId]) {
        
    }
    else {
        [[CBIMDataSource sharedInstance] getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            NSString* nickname = [NSString stringWithFormat:@"%@%@", [_childInfo name], relationship.relationship];
            CBIMChatViewController *conversationVC = [[CBIMChatViewController alloc]init];
            conversationVC.conversationType = ConversationType_PRIVATE;
            conversationVC.targetId = userId;
            conversationVC.title = nickname;
            
            [self.navigationController pushViewController:conversationVC animated:YES];
        }];
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

#pragma mark - CSChildProfileHeaderViewControllerDelegate
- (void)childProfileHeaderViewControllerShowChating:(CSChildProfileHeaderViewController*)ctrl {
    //[self performSegueWithIdentifier:@"segue.childprofile.chating" sender:nil];
}

- (void)childProfileHeaderViewControllerShowAssessment:(CSChildProfileHeaderViewController*)ctrl {
    [self performSegueWithIdentifier:@"segue.childprofile.assessment" sender:nil];
}

@end

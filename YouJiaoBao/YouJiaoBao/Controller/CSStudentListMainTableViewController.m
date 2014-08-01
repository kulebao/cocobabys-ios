//
//  CSStudentListMainTableViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-7-20.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSStudentListMainTableViewController.h"
#import "CSHttpClient.h"
#import "CSEngine.h"
#import "EntityClassInfoHelper.h"

@interface CSStudentListMainTableViewController ()
- (IBAction)onRefreshClicked:(id)sender;

@end

@implementation CSStudentListMainTableViewController

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
    
    [self customizeBackBarItem];
    [self doRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onRefreshClicked:(id)sender {
    [self doRefresh];
}

- (void)doRefresh {
    [self doReloadClassList];
}

- (void)doReloadClassList {
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* classInfoList = [EntityClassInfoHelper updateEntities:responseObject
                                                           forEmployee:engine.loginInfo.uid
                                                        ofKindergarten:engine.loginInfo.schoolId.integerValue];
        [self doReloadChildList:classInfoList];
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
    };
    
    [http opGetClassListOfKindergarten:engine.loginInfo.schoolId.integerValue
                        withEmployeeId:engine.loginInfo.phone
                      success:success
                      failure:failure];
}

- (void)doReloadChildList:(NSArray*)classInfoList{
    NSMutableArray* classIdList = [NSMutableArray array];
    for (EntityClassInfo* classInfo in classInfoList) {
        [classIdList addObject:classInfo.classId];
    }
 
    CSHttpClient* http = [CSHttpClient sharedInstance];
    CSEngine* engine = [CSEngine sharedInstance];
    
    id success = ^(AFHTTPRequestOperation *operation, id po) {
        /*
         address = "";
         birthday = "2014-06-26";
         "child_id" = "2_2088_896";
         "class_id" = 33;
         "class_name" = "\U5e93\U8d1d";
         gender = 1;
         name = "\U5b8b\U5dcd";
         nick = "\U5b8b\U5dcd";
         portrait = "https://dn-cocobabys.qbox.me/child_photo/2088/2_2088_896/2_2088_896.jpg";
         "school_id" = 2088;
         status = 1;
         timestamp = 1405060847820;
         */
    };
    
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
    };
    
    [http opGetChildListOfKindergarten:engine.loginInfo.schoolId.integerValue
                         withClassList:classIdList
                               success:success
                               failure:failure];
}

@end

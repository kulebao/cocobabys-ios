//
//  CSKuleChatingViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleChatingViewController.h"
#import "CSKuleNoticeCell.h"
#import "PullTableView.h"

@interface CSKuleChatingViewController () <UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
@property (weak, nonatomic) IBOutlet PullTableView *tableview;
- (IBAction)onBtnEditorClicked:(id)sender;
- (IBAction)onBtnCameraClicked:(id)sender;
- (IBAction)onBtnPhotosClicked:(id)sender;

@end

@implementation CSKuleChatingViewController


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
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.pullDelegate = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.pullBackgroundColor = [UIColor clearColor];
    self.tableview.pullTextColor = UIColorRGB(0xCC, 0x66, 0x33);
    self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
    
    /* manually triggering
     if(!self.pullTableView.pullTableIsRefreshing) {
     self.pullTableView.pullTableIsRefreshing = YES;
     [self performSelector:@selector(refreshTable) withObject:nil afterDelay:3];
     }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleNoticeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleNoticeCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleNoticeCell" owner:nil options:nil];
        cell = [nibs firstObject];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [self performSelector:@selector(refreshTable)
               withObject:nil
               afterDelay:3.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    [self performSelector:@selector(loadMoreDataToTable)
               withObject:nil
               afterDelay:3.0f];
}

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.tableview.pullLastRefreshDate = [NSDate date];
    self.tableview.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    self.tableview.pullTableIsLoadingMore = NO;
}


#pragma mark - UI Actions

- (IBAction)onBtnEditorClicked:(id)sender {
    [self performSegueWithIdentifier:@"segue.chatingEditor" sender:nil];
}

- (IBAction)onBtnCameraClicked:(id)sender {
}

- (IBAction)onBtnPhotosClicked:(id)sender {
}

@end

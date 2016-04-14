//
//  CSKuleSelectChildViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-6.
//  Copyright (c) 2014-2016 Cocobabys. All rights reserved.
//

#import "CSKuleSelectChildViewController.h"
#import "CSKuleChildCell.h"
#import "CSAppDelegate.h"
#import "UIImageView+WebCache.h"

@interface CSKuleSelectChildViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray* relationships;

@end

@implementation CSKuleSelectChildViewController
@synthesize relationships = _relationships;

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
    
    
    self.relationships = gApp.engine.relationships;
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    
    /*
     self.tableview.pullDelegate = self;
     self.tableview.pullBackgroundColor = [UIColor clearColor];
     self.tableview.pullTextColor = UIColorRGB(0x99, 0x99, 0x99);
     self.tableview.pullArrowImage = [UIImage imageNamed:@"grayArrow.png"];
     */
    
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

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.relationships.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleChildCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleChildCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleChildCell" owner:nil options:nil];
        cell = [nibs firstObject];
        
        cell.imgChildPortrait.layer.cornerRadius = 56.0/2;
        cell.imgChildPortrait.clipsToBounds = YES;
    }
    
    CSKuleRelationshipInfo* relationship = [self.relationships objectAtIndex:indexPath.row];
    cell.labChildName.text = relationship.child.nick;
    
    NSURL* qiniuImgUrl = [gApp.engine urlFromPath:relationship.child.portrait];
    qiniuImgUrl = [qiniuImgUrl URLByQiniuImageView:@"/1/w/256/h/256"];
    
    [cell.imgChildPortrait sd_setImageWithURL:qiniuImgUrl
                             placeholderImage:[UIImage imageNamed:@"default_child_head_icon.png"]
                                      options:SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageAllowInvalidSSLCertificates];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleRelationshipInfo* relationship = [self.relationships objectAtIndex:indexPath.row];
    gApp.engine.currentRelationship = relationship;
    [gApp alert:@"切换成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI Actions

@end

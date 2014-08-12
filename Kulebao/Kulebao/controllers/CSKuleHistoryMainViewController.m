//
//  CSKuleHistoryMainViewController.m
//  youlebao
//
//  Created by xin.c.wang on 14-8-12.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleHistoryMainViewController.h"
#import "CSKuleHistoryMonthCell.h"
#import "CSKuleHistoryListTableViewController.h"

@interface CSKuleHistoryMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)onBtnLeftClicked:(id)sender;
- (IBAction)onBtnRightClicked:(id)sender;

@end

@implementation CSKuleHistoryMainViewController

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
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
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
    if ([segue.identifier isEqualToString:@"segue.history.list"]) {
        CSKuleHistoryListTableViewController* ctrl = segue.destinationViewController;
        ctrl.navigationItem.title = sender;
    }
}

- (IBAction)onBtnLeftClicked:(id)sender {
}

- (IBAction)onBtnRightClicked:(id)sender {
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleHistoryMonthCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSKuleHistoryMonthCell" forIndexPath:indexPath];
    
    cell.labTitle.text = [NSString stringWithFormat:@"%d月", indexPath.row+1];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"segue.history.list" sender:@"2013-01"];
}



@end

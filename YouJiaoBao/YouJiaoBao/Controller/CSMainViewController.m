//
//  CSMainViewController.m
//  YouJiaoBao
//
//  Created by xin.c.wang on 14-8-1.
//  Copyright (c) 2014年 Codingsoft. All rights reserved.
//

#import "CSMainViewController.h"

@interface CSMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray* _modules;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CSMainViewController

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"header.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont: [UIFont systemFontOfSize:20], UITextAttributeTextColor:[UIColor whiteColor]}];
    
    _modules = @[@{@"icon": [UIImage imageNamed:@"notice.png"],
                   @"segue": @"segue.main.notice",
                   @"name": @"园内公告"},
                 
                 @{@"icon": [UIImage imageNamed:@"babylist.png"],
                   @"segue": @"segue.main.babylist",
                   @"name": @"宝宝列表"},
                 
                 @{@"icon": [UIImage imageNamed:@"growexp.png"],
                   @"segue": @"segue.main.growexp",
                   @"name": @"成长经历"},
                 
                 @{@"icon": [UIImage imageNamed:@"hw.png"],
                   @"segue": @"segue.main.hw",
                   @"name": @"亲子作业"},
                 
                 @{@"icon": [UIImage imageNamed:@"setting.png"],
                   @"segue": @"segue.main.setting",
                   @"name": @"设置"}
                 ];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _modules.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"main.module.cell" forIndexPath:indexPath];
    
    UIImageView* imgView = (UIImageView*)[cell viewWithTag:100];
    NSDictionary* module = [_modules objectAtIndex:indexPath.row];
    imgView.image = [module objectForKey:@"icon"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSDictionary* module = [_modules objectAtIndex:indexPath.row];
    NSString* segueName = [module objectForKey:@"segue"];
    
    [self performSegueWithIdentifier:segueName sender:nil];
}

@end

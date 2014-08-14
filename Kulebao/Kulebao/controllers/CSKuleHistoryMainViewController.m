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
#import "CSAppDelegate.h"

@interface CSKuleHistoryMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSInteger _year;
}
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSCalendar* calendar;

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
    [self customizeOkBarItemWithTarget:self action:@selector(onBtnCreateNewClicked:) text:@"创建"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.calendar = [NSCalendar currentCalendar];
    
    NSDate* now = [NSDate date];
    NSDateComponents* components = [self.calendar components:NSCalendarUnitYear fromDate:now];
    
    _year = components.year;
    self.labTitle.text = [NSString stringWithFormat:@"%d", _year];
    
    [self doReloadHistory];
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
        NSIndexPath* indexPath = sender;
        CSKuleHistoryListTableViewController* ctrl = segue.destinationViewController;
        ctrl.navigationItem.title = [NSString stringWithFormat:@"%d-%02d", _year, indexPath.row+1];
        ctrl.year = _year;
        ctrl.month = indexPath.row + 1;
    }
}

- (IBAction)onBtnLeftClicked:(id)sender {
    --_year;
    self.labTitle.text = [NSString stringWithFormat:@"%d", _year];
    
    [self doReloadHistory];
}

- (IBAction)onBtnRightClicked:(id)sender {
    ++_year;
    self.labTitle.text = [NSString stringWithFormat:@"%d", _year];
    
    [self doReloadHistory];
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
    [self performSegueWithIdentifier:@"segue.history.list" sender:indexPath];
}

- (void)onBtnCreateNewClicked:(id)sender {
    
}

- (void)doReloadHistory {
    NSString* fromDateString = [NSString stringWithFormat:@"%d-01-01 00:00:00", _year];
    NSString* toDateString = [NSString stringWithFormat:@"%d-12-31 23:59:59", _year];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate* fromDate = [fmt dateFromString:fromDateString];
    NSDate* toDate = [fmt dateFromString:toDateString];
    
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        /*
         {
         content = "\U6d4b\U8bd5\U770b\U7f51\U9875\U663e\U793a\U95ee\U9898";
         id = 796;
         medium =     (
         {
         type = image;
         url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_180338.jpg";
         },
         {
         type = image;
         url = "https://dn-cocobabys.qbox.me/2088/exp_cion/IMG_20140726_145407.jpg";
         }
         );
         sender =     {
         id = "3_2088_1403762507321";
         type = t;
         };
         timestamp = 1406449306043;
         topic = "2_2088_900";
         },
         */
        
        [gApp hideAlert];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:error.localizedDescription];
    };
    
    [gApp.engine reqGetHistoryListOfKindergarten:gApp.engine.loginInfo.schoolId
                                     withChildId:gApp.engine.currentRelationship.child.childId
                                        fromDate:fromDate
                                          toDate:toDate
                                         success:sucessHandler
                                         failure:failureHandler];
}

@end

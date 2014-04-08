//
//  CSKuleRecipeViewController.m
//  Kulebao
//
//  Created by xin.c.wang on 14-3-4.
//  Copyright (c) 2014年 Cocobabys. All rights reserved.
//

#import "CSKuleRecipeViewController.h"
#import "CSKuleRecipeCell.h"
#import "CSAppDelegate.h"

@interface CSKuleRecipeViewController ()<UITableViewDataSource, UITableViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) CSKuleCookbookInfo* currentCookbookInfo;

@end

@implementation CSKuleRecipeViewController
@synthesize currentCookbookInfo = _currentCookbookInfo;

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
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self reloadCookbooks];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
-(void) viewDidAppear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@",  self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
}

-(void) viewDidDisappear:(BOOL)animated
{
    NSString* cName = [NSString stringWithFormat:@"%@", self.navigationItem.title, nil];
    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = _currentCookbookInfo ? 5 : 0;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSKuleRecipeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CSKuleRecipeCell"];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CSKuleRecipeCell" owner:nil options:nil];
        cell = [nibs firstObject];
        cell.clipsToBounds = YES;
    }
    
    NSInteger row = indexPath.row;
    
    CSKuleRecipeInfo* recipeInfo = nil;
    
    
    NSDate* beginningOfWeek = [[NSDate date] beginningOfWeek];
    
    NSString* dateText = nil;
    switch (row) {
        case 0:
        {
            recipeInfo = _currentCookbookInfo.mon;
            NSDate* day = [beginningOfWeek dateByAddingTimeInterval:24*60*60*1];
            dateText = [NSString stringWithFormat:@"星期一 %@", [day isoDateString]];
        }
            break;
        case 1:
        {
            recipeInfo = _currentCookbookInfo.tue;
            NSDate* day = [beginningOfWeek dateByAddingTimeInterval:24*60*60*2];
            dateText = [NSString stringWithFormat:@"星期二 %@", [day isoDateString]];
        }
            break;
        case 2:
        {
            recipeInfo = _currentCookbookInfo.wed;
            NSDate* day = [beginningOfWeek dateByAddingTimeInterval:24*60*60*3];
            dateText = [NSString stringWithFormat:@"星期三 %@", [day isoDateString]];
        }
            break;
        case 3:
        {
            recipeInfo = _currentCookbookInfo.thu;
            NSDate* day = [beginningOfWeek dateByAddingTimeInterval:24*60*60*4];
            dateText = [NSString stringWithFormat:@"星期四 %@", [day isoDateString]];
        }
            break;
        case 4:
        {
            recipeInfo = _currentCookbookInfo.fri;
            NSDate* day = [beginningOfWeek dateByAddingTimeInterval:24*60*60*5];
            dateText = [NSString stringWithFormat:@"星期五 %@", [day isoDateString]];
        }
            break;
        default:
            break;
    }
    
    if (recipeInfo) {
        cell.labBreakfast.text = recipeInfo.breakfast;
        cell.labLunch.text = recipeInfo.lunch;
        cell.labExtra.text = recipeInfo.extra;
        cell.labDinner.text = recipeInfo.dinner;
    }
    else {
        cell.labBreakfast.text = nil;
        cell.labLunch.text = nil;
        cell.labExtra.text = nil;
        cell.labDinner.text = nil;
    }
    
    cell.labDate.text = dateText;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    CSKuleRecipeInfo* recipeInfo = nil;
    
    switch (row) {
        case 0:
            recipeInfo = _currentCookbookInfo.mon;
            break;
        case 1:
            recipeInfo = _currentCookbookInfo.tue;
            break;
        case 2:
            recipeInfo = _currentCookbookInfo.wed;
            break;
        case 3:
            recipeInfo = _currentCookbookInfo.thu;
            break;
        case 4:
            recipeInfo = _currentCookbookInfo.fri;
            break;
        default:
            break;
    }
    
    CGFloat rowHeight = recipeInfo ? (290.0 + 10.0) : 0.0;
    
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UI Actions


#pragma mark - Private
- (void)reloadCookbooks {
    SuccessResponseHandler sucessHandler = ^(AFHTTPRequestOperation *operation, id dataJson) {
        NSMutableArray* cookbooks = [NSMutableArray array];
        
        for (id cookbookJson in dataJson) {
            CSKuleCookbookInfo* cookbookInfo = [CSKuleInterpreter decodeCookbookInfo:cookbookJson];
            [cookbooks addObject:cookbookInfo];
        }
        
        if (cookbooks.count > 0) {
            CSKuleCookbookInfo* cookbookInfo = [cookbooks firstObject];
            if (cookbookInfo.errorCode == 0) {
                _currentCookbookInfo = cookbookInfo;
                
                [gApp hideAlert];
            }
            else {
                [gApp alert:@"获取数据失败"];
            }
        }
        else {
            [gApp alert:@"没有食谱信息"];
        }
        
        [self.tableview reloadData];
    };
    
    FailureResponseHandler failureHandler = ^(AFHTTPRequestOperation *operation, NSError *error) {
        CSLog(@"failure:%@", error);
        [gApp alert:[error localizedDescription]];
    };
    
    [gApp waitingAlert:@"正在获取数据"];
    [gApp.engine reqGetCookbooksOfKindergarten:gApp.engine.loginInfo.schoolId
                                       success:sucessHandler
                                       failure:failureHandler];
}

@end
